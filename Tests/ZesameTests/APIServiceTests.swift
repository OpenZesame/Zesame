import Combine
import Foundation
import Testing
@testable import Zesame

// MARK: - Mock helpers

private enum APITestError: Swift.Error { case typeMismatch }

private struct MockAPIClient: APIClient {
    /// Handler is keyed on the wire-level method name; it returns a type-erased decoded value
    /// that ``send(method:)`` then downcasts to the call site's expected `Response`.
    let handler: @Sendable (String) async throws -> any Decodable

    func send<Response: Decodable>(method: RPCMethod<Response>) async throws -> Response {
        let result = try await handler(method.name)
        guard let typed = result as? Response else {
            throw Zesame.Error.api(.request(APITestError.typeMismatch))
        }
        return typed
    }
}

private func makeService(
    handler: @escaping @Sendable (String) async throws -> any Decodable
) -> DefaultZilliqaService {
    DefaultZilliqaService(apiClient: MockAPIClient(handler: handler))
}

private func makeNetworkResponse() throws -> NetworkResponse {
    try JSONDecoder().decode(NetworkResponse.self, from: Data("\"1\"".utf8))
}

private func makeBalanceResponse() throws -> BalanceResponse {
    try BalanceResponse(balance: Amount(qa: "5000000"), nonce: Nonce(3))
}

private func makeMinGasPriceResponse() throws -> MinimumGasPriceResponse {
    // Use the default minimum to avoid mutating GasPrice.minInQa to a surprising value
    let qaString = String(GasPrice.minInQaDefault)
    return try JSONDecoder().decode(MinimumGasPriceResponse.self, from: Data("\"\(qaString)\"".utf8))
}

private func makeTransactionResponse() throws -> TransactionResponse {
    try JSONDecoder().decode(TransactionResponse.self, from: Data(#"{"TranID":"abc123","Info":"Sent"}"#.utf8))
}

private func makeSuccessStatusResponse() throws -> StatusOfTransactionResponse {
    try JSONDecoder().decode(
        StatusOfTransactionResponse.self,
        from: Data(#"{"receipt":{"cumulative_gas":"1","success":true}}"#.utf8)
    )
}

private func makePendingStatusResponse() throws -> StatusOfTransactionResponse {
    try JSONDecoder().decode(
        StatusOfTransactionResponse.self,
        from: Data(#"{"receipt":{"cumulative_gas":"1","success":false}}"#.utf8)
    )
}

private let apiTestPrivKey = try! PrivateKey(
    rawRepresentation: Data(hex: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638")
)
private let apiTestPassword = "apabanan"
private let apiTestRecipient = try! LegacyAddress(string: "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039")

// MARK: - DefaultZilliqaService API method tests

struct DefaultZilliqaServiceAPITests {
    @Test func getNetworkFromAPI() async throws {
        let expected = try makeNetworkResponse()
        let service = makeService { _ in expected }
        let result = try await service.getNetworkFromAPI()
        #expect(result.network == .mainnet)
    }

    @Test func getBalance() async throws {
        let expected = try makeBalanceResponse()
        let service = makeService { _ in expected }
        let result = try await service.getBalance(for: apiTestRecipient)
        #expect(result.balance.qa > 0)
        #expect(result.nonce.nonce == 3)
    }

    @Test func getMinimumGasPriceUpdatesCache() async throws {
        let expected = try makeMinGasPriceResponse()
        let service = makeService { _ in expected }
        let result = try await service.getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: true)
        #expect(result.amount.qa == GasPrice.minInQa)
    }

    @Test func getMinimumGasPriceSkipsCache() async throws {
        let expected = try makeMinGasPriceResponse()
        let service = makeService { _ in expected }
        let before = GasPrice.minInQa
        let result = try await service.getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: false)
        #expect(result.amount.qa > 0)
        #expect(GasPrice.minInQa == before)
    }

    @Test func sendSignedTransaction() async throws {
        let expected = try makeTransactionResponse()
        let service = makeService { _ in expected }
        let keyPair = KeyPair(private: apiTestPrivKey)
        let payment = Payment.withMinimumGasLimit(
            to: apiTestRecipient,
            amount: 1,
            gasPrice: GasPrice.min,
            nonce: 0
        )
        let signed = try service.sign(payment: payment, using: keyPair, network: .mainnet)
        let result = try await service.send(transaction: signed)
        #expect(result.transactionIdentifier == "abc123")
    }
}

// MARK: - Poll transaction tests (1s sleep per test)

struct PollTransactionTests {
    @Test(.timeLimit(.minutes(1)))
    func successOnFirstPoll() async throws {
        let txId = "pollTxSuccess"
        let successStatus = try makeSuccessStatusResponse()
        let service = makeService { _ in successStatus }
        let polling = Polling(.once, backoff: .linearIncrement(of: .oneSecond), initialDelay: .oneSecond)
        let receipt = try await service.hasNetworkReachedConsensusYetForTransactionWith(
            id: txId, polling: polling
        )
        #expect(receipt.transactionId == txId)
        #expect(receipt.totalGasCost.qa >= 0)
    }

    @Test(.timeLimit(.minutes(1)))
    func timeoutAfterExhaustedRetries() async throws {
        let txId = "pollTxTimeout"
        let pendingStatus = try makePendingStatusResponse()
        let service = makeService { _ in pendingStatus }
        let polling = Polling(.once, backoff: .linearIncrement(of: .oneSecond), initialDelay: .oneSecond)
        var timedOut = false
        do {
            _ = try await service.hasNetworkReachedConsensusYetForTransactionWith(
                id: txId, polling: polling
            )
        } catch {
            timedOut = true
        }
        #expect(timedOut)
    }
}

// MARK: - Combine extension tests (not yet covered)

struct CombineExtendedTests {
    @Test func getNetworkFromAPIViaCombine() async throws {
        let expected = try makeNetworkResponse()
        let service = makeService { _ in expected }
        let result: NetworkResponse = try await withCheckedThrowingContinuation { cont in
            var c: AnyCancellable?
            c = service.combine.getNetworkFromAPI()
                .sink(
                    receiveCompletion: { if case let .failure(e) = $0 { cont.resume(throwing: e) }; _ = c },
                    receiveValue: { cont.resume(returning: $0); _ = c }
                )
        }
        #expect(result.network == .mainnet)
    }

    @Test func getMinimumGasPriceViaCombine() async throws {
        let expected = try makeMinGasPriceResponse()
        let service = makeService { _ in expected }
        let result: MinimumGasPriceResponse = try await withCheckedThrowingContinuation { cont in
            var c: AnyCancellable?
            c = service.combine.getMinimumGasPrice()
                .sink(
                    receiveCompletion: { if case let .failure(e) = $0 { cont.resume(throwing: e) }; _ = c },
                    receiveValue: { cont.resume(returning: $0); _ = c }
                )
        }
        #expect(result.amount.qa > 0)
    }

    @Test func getBalanceViaCombine() async throws {
        let expected = try makeBalanceResponse()
        let service = makeService { _ in expected }
        let result: BalanceResponse = try await withCheckedThrowingContinuation { cont in
            var c: AnyCancellable?
            c = service.combine.getBalance(for: apiTestRecipient)
                .sink(
                    receiveCompletion: { if case let .failure(e) = $0 { cont.resume(throwing: e) }; _ = c },
                    receiveValue: { cont.resume(returning: $0); _ = c }
                )
        }
        #expect(result.balance.qa > 0)
    }

    @Test func sendTransactionSignWithKeyPairViaCombine() async throws {
        let expected = try makeTransactionResponse()
        let service = makeService { _ in expected }
        let keyPair = KeyPair(private: apiTestPrivKey)
        let payment = Payment.withMinimumGasLimit(
            to: apiTestRecipient,
            amount: 1,
            gasPrice: GasPrice.min,
            nonce: 0
        )
        let result: TransactionResponse = try await withCheckedThrowingContinuation { cont in
            var c: AnyCancellable?
            c = service.combine.sendTransaction(for: payment, signWith: keyPair, network: .mainnet)
                .sink(
                    receiveCompletion: { if case let .failure(e) = $0 { cont.resume(throwing: e) }; _ = c },
                    receiveValue: { cont.resume(returning: $0); _ = c }
                )
        }
        #expect(result.transactionIdentifier == "abc123")
    }

    @Test func sendTransactionWithKeystoreViaCombine() async throws {
        let expected = try makeTransactionResponse()
        let service = makeService { _ in expected }
        let keystore = try Keystore.makeTest()
        let payment = Payment.withMinimumGasLimit(
            to: apiTestRecipient,
            amount: 1,
            gasPrice: GasPrice.min,
            nonce: 0
        )
        let result: TransactionResponse = try await withCheckedThrowingContinuation { cont in
            var c: AnyCancellable?
            c = service.combine.sendTransaction(
                for: payment, keystore: keystore, password: apiTestPassword, network: .mainnet
            )
            .sink(
                receiveCompletion: { if case let .failure(e) = $0 { cont.resume(throwing: e) }; _ = c },
                receiveValue: { cont.resume(returning: $0); _ = c }
            )
        }
        #expect(result.transactionIdentifier == "abc123")
    }

    @Test(.timeLimit(.minutes(1)))
    func pollTransactionViaCombine() async throws {
        let txId = "combinePollTx"
        let successStatus = try makeSuccessStatusResponse()
        let service = makeService { _ in successStatus }
        let polling = Polling(.once, backoff: .linearIncrement(of: .oneSecond), initialDelay: .oneSecond)
        let receipt: TransactionReceipt = try await withCheckedThrowingContinuation { cont in
            var c: AnyCancellable?
            c = service.combine.hasNetworkReachedConsensusYetForTransactionWith(id: txId, polling: polling)
                .sink(
                    receiveCompletion: { if case let .failure(e) = $0 { cont.resume(throwing: e) }; _ = c },
                    receiveValue: { cont.resume(returning: $0); _ = c }
                )
        }
        #expect(receipt.transactionId == txId)
    }

    @Test(.timeLimit(.minutes(1)))
    func pollTransactionViaCombineDefaultPolling() async throws {
        let txId = "combinePollTxDefault"
        let successStatus = try makeSuccessStatusResponse()
        let service = makeService { _ in successStatus }
        let receipt: TransactionReceipt = try await withCheckedThrowingContinuation { cont in
            var c: AnyCancellable?
            c = service.combine.hasNetworkReachedConsensusYetForTransactionWith(id: txId)
                .sink(
                    receiveCompletion: { if case let .failure(e) = $0 { cont.resume(throwing: e) }; _ = c },
                    receiveValue: { cont.resume(returning: $0); _ = c }
                )
        }
        #expect(receipt.transactionId == txId)
    }
}
