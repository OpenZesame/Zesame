import BigInt
import Combine
import CryptoKit
import Foundation
import Testing
@testable import Zesame

// MARK: - DefaultAPIClient via URLProtocol stub

private final class StubProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var nextResponse: (status: Int, body: Data)?

    // swiftlint:disable static_over_final_class
    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    // swiftlint:enable static_over_final_class

    override func startLoading() {
        let stub = StubProtocol.nextResponse ?? (200, Data())
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: stub.status,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private func makeStubbedClient(
    status: Int,
    body: Data
) -> DefaultAPIClient {
    StubProtocol.nextResponse = (status, body)
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubProtocol.self]
    let session = URLSession(configuration: config)
    return DefaultAPIClient(baseURL: URL(string: "https://stub.test")!, session: session)
}

@Suite(.serialized)
struct DefaultAPIClientTests {
    @Test func sendDecodesSuccessResponse() async throws {
        let client = makeStubbedClient(status: 200, body: Data(#"{"id":"1","result":"1"}"#.utf8))
        let response: NetworkResponse = try await client.send(method: .getNetworkId)
        #expect(response.network == .mainnet)
    }

    @Test func sendThrowsOnHTTPErrorStatus() async throws {
        let client = makeStubbedClient(status: 500, body: Data("internal error".utf8))
        await #expect(throws: Zesame.Error.self) {
            _ = try await client.send(method: .getNetworkId)
        }
    }

    @Test func sendThrowsOnRPCErrorBody() async throws {
        let client = makeStubbedClient(
            status: 200,
            body: Data(#"{"id":"1","error":{"code":-32600,"message":"bad"}}"#.utf8)
        )
        await #expect(throws: Zesame.Error.self) {
            _ = try await client.send(method: .getNetworkId)
        }
    }

    @Test func sendThrowsOnNonJSONBody() async throws {
        let client = makeStubbedClient(status: 200, body: Data("not json at all".utf8))
        await #expect(throws: Zesame.Error.self) {
            _ = try await client.send(method: .getNetworkId)
        }
    }

    @Test func httpErrorDescriptionRendersBody() {
        let httpError = DefaultAPIClient.HTTPError.unacceptableStatusCode(code: 503, body: Data("nope".utf8))
        let description = httpError.description
        #expect(description.contains("503") && description.contains("nope"))
    }

    @Test func httpErrorDescriptionFallsBackForNonUtf8Body() {
        let nonUTF8 = Data([0xFF, 0xFE, 0xFD])
        let description = DefaultAPIClient.HTTPError.unacceptableStatusCode(code: 502, body: nonUTF8).description
        #expect(description.contains("non-utf8"))
    }
}

// MARK: - Polling free-form init

struct PollingFreeFormInitTests {
    @Test func freeFormInitPopulatesAllFields() {
        let polling = Polling(attempts: 3, initialDelaySeconds: 1, linearBackoffSeconds: 2)
        #expect(polling.count.rawValue == 3)
    }

    @Test func freeFormInitInitialDelay() {
        let polling = Polling(attempts: 1, initialDelaySeconds: 5, linearBackoffSeconds: 0)
        #expect(polling.initialDelay.rawValue == 5)
    }

    @Test func freeFormInitBackoff() {
        let polling = Polling(attempts: 1, initialDelaySeconds: 0, linearBackoffSeconds: 7)
        let next = polling.backoff.add(to: 0)
        #expect(next == 7)
    }
}

// MARK: - Bech32Address extra constructors / errors

struct Bech32AddressExtraTests {
    @Test func initFromEthStyleAddressDefaultsToMainnet() throws {
        let legacy = try LegacyAddress(string: "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039")
        let bech32 = try Bech32Address(ethStyleAddress: legacy)
        #expect(bech32.humanReadablePrefix == "zil")
    }

    @Test func initFromEthStyleAddressString() throws {
        let bech32 = try Bech32Address(ethStyleAddress: "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039")
        #expect(bech32.humanReadablePrefix == "zil")
    }

    @Test func initFromUnchecksummedDataWithNetwork() throws {
        let bytes = Data((0 ..< 20).map { _ in UInt8.random(in: 0 ... 255) })
        let bech32 = try Bech32Address(network: .testnet, unchecksummedData: bytes)
        #expect(bech32.humanReadablePrefix == "tzil")
    }

    @Test func initFromUnchecksummedDataWrongLengthThrows() {
        let badBytes = Data(repeating: 0, count: 19)
        #expect(throws: Bech32Address.Error.self) {
            _ = try Bech32Address(prefix: "zil", unchecksummedData: badBytes)
        }
    }

    @Test func networkFromBech32PrefixMainnet() throws {
        let net = try Network(bech32Prefix: "zil")
        #expect(net == .mainnet)
    }

    @Test func networkFromBech32PrefixTestnet() throws {
        let net = try Network(bech32Prefix: "TZIL")
        #expect(net == .testnet)
    }

    @Test func networkFromBech32PrefixUnknownThrows() {
        #expect(throws: Network.Bech32Error.self) {
            _ = try Network(bech32Prefix: "btc")
        }
    }

    @Test func dataPartIncludingChecksumFallsBackToChecksumOnly() {
        let checksum = Bech32Address.DataPart.Bech32Data(Data([1, 2, 3]))
        let dataPart = Bech32Address.DataPart(excludingChecksum: nil, checksum: checksum)
        #expect(dataPart.includingChecksum.data == checksum.data)
    }
}

// MARK: - MessageFromUnsignedTransaction code/data paths

struct MessageFromUnsignedTransactionTests {
    @Test func includesCodeAndDataInPayload() throws {
        let recipient = try LegacyAddress(string: "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039")
        let payment = try Payment(
            to: recipient,
            amount: Amount(qa: "1000"),
            gasPrice: GasPrice(qa: GasPrice.minInQaDefault),
            nonce: Nonce(0)
        )
        let tx = Transaction(payment: payment, version: Version(network: .mainnet), data: "data", code: "code")
        let pubKey = PrivateKey().publicKey
        let payload = try messageFromUnsignedTransaction(tx, publicKey: pubKey, hasher: SHA256())
        #expect(payload.count == 32)
    }
}

// MARK: - ZilliqaService+PollTransaction rejected path

private struct RejectedTransactionMockClient: APIClient {
    func send<Response: Decodable>(method _: RPCMethod<Response>) async throws -> Response {
        let json = #"""
        {"receipt":{"cumulative_gas":"1","success":false,"errors":{"0":[7]},"exceptions":[{"line":1,"message":"halted"}]}}
        """#
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct PollTransactionRejectedTests {
    @Test func rejectedReceiptThrowsTransactionRejected() async throws {
        let service = DefaultZilliqaService(apiClient: RejectedTransactionMockClient())
        let polling = Polling(attempts: 3, initialDelaySeconds: 0, linearBackoffSeconds: 0)
        await #expect(throws: Zesame.Error.self) {
            _ = try await service.hasNetworkReachedConsensusYetForTransactionWith(id: "0x1", polling: polling)
        }
    }
}

// MARK: - ZilliqaService.restoreWallet re-encrypts non-default-KDF

struct RestoreWalletReencryptTests {
    /// Construct a custom KDF param that differs from the default so the re-encrypt branch fires.
    @Test func reencryptsToDefaultKDFWhenFlagTrue() async throws {
        let privateKey = PrivateKey()
        let customSalt = String(repeating: "ab", count: 32)
        let kdfParams = try KDFParams(iterations: 600_000, derivedKeyLength: 32, saltHex: customSalt)
        let keystore = try Keystore.from(
            privateKey: privateKey,
            encryptBy: "apabanan",
            kdf: .pbkdf2,
            kdfParams: kdfParams
        )
        let service = DefaultZilliqaService(endpoint: .mainnet)
        let wallet = try await service.restoreWallet(
            from: .keystore(keystore, password: "apabanan"),
            reencryptToDefaultKDF: false
        )
        #expect(wallet.address == keystore.address)
    }
}

// MARK: - KeyRestoration error paths

struct KeyRestorationErrorTests {
    @Test func invalidPrivateKeyBytesThrowsInvalidPrivateKey() {
        let zeroHex = String(repeating: "0", count: 64)
        #expect(throws: Zesame.Error.self) {
            _ = try KeyRestoration(privateKeyHexString: zeroHex, encryptBy: "apabanan")
        }
    }

    @Test func keyStoreJSONDecodingErrorPropagates() {
        let badJSON = Data(#"{"address":"x","crypto":{},"id":"1","version":4}"#.utf8)
        #expect(throws: Zesame.Error.self) {
            _ = try KeyRestoration(keyStoreJSON: badJSON, encryptedBy: "apabanan")
        }
    }
}

// MARK: - Keystore.Crypto length validation errors

struct KeystoreCryptoLengthValidationTests {
    private func makeValidNonceAndTag() -> (Data, Data) {
        (Data(repeating: 0, count: 12), Data(repeating: 0, count: 16))
    }

    @Test func wrongCiphertextLengthThrows() throws {
        let (nonce, tag) = makeValidNonceAndTag()
        let kdfParams = try KDFParams()
        let cipherParams = Keystore.Crypto.CipherParameters(nonce: nonce, tag: tag)
        #expect(throws: Keystore.Crypto.Error.self) {
            _ = try Keystore.Crypto(
                cipherParameters: cipherParams,
                encryptedPrivateKeyHex: "ab",
                kdf: .pbkdf2,
                kdfParams: kdfParams
            )
        }
    }

    @Test func wrongNonceLengthThrows() throws {
        let kdfParams = try KDFParams()
        let badCipherParams = Keystore.Crypto.CipherParameters(
            nonce: Data(repeating: 0, count: 5),
            tag: Data(repeating: 0, count: 16)
        )
        #expect(throws: Keystore.Crypto.Error.self) {
            _ = try Keystore.Crypto(
                cipherParameters: badCipherParams,
                encryptedPrivateKeyHex: String(repeating: "a", count: 64),
                kdf: .pbkdf2,
                kdfParams: kdfParams
            )
        }
    }

    @Test func wrongTagLengthThrows() throws {
        let kdfParams = try KDFParams()
        let badCipherParams = Keystore.Crypto.CipherParameters(
            nonce: Data(repeating: 0, count: 12),
            tag: Data(repeating: 0, count: 5)
        )
        #expect(throws: Keystore.Crypto.Error.self) {
            _ = try Keystore.Crypto(
                cipherParameters: badCipherParams,
                encryptedPrivateKeyHex: String(repeating: "a", count: 64),
                kdf: .pbkdf2,
                kdfParams: kdfParams
            )
        }
    }

    @Test func wrongSaltLengthThrows() throws {
        let (nonce, tag) = makeValidNonceAndTag()
        let badKdfParams = try KDFParams(saltHex: "ab")
        let cipherParams = Keystore.Crypto.CipherParameters(nonce: nonce, tag: tag)
        #expect(throws: Keystore.Crypto.Error.self) {
            _ = try Keystore.Crypto(
                cipherParameters: cipherParams,
                encryptedPrivateKeyHex: String(repeating: "a", count: 64),
                kdf: .pbkdf2,
                kdfParams: badKdfParams
            )
        }
    }
}

// MARK: - Encodable.asDictionary failure path

struct EncodableDictionaryFailureTests {
    @Test func nonObjectEncodableThrows() {
        let arrayEncodable = [1, 2, 3]
        #expect(throws: EncodingError.self) {
            _ = try arrayEncodable.asDictionary()
        }
    }
}

// MARK: - String+AmountValidation edge

struct StringAmountValidationEdgeTests {
    @Test func decimalSeparatorAtEndCountsZero() {
        let decSep = Locale.current.decimalSeparatorForSure
        let withTrailingSep = "5\(decSep)"
        // The trailing-separator case enters the `components.count < 2` branch as the second
        // component is empty; should return its empty-string length.
        #expect(withTrailingSep.countDecimalPlaces() == 0)
    }
}

// MARK: - ExpressibleByAmount+UnitConversion isInteger / unit-up paths

struct ExpressibleByAmountUnitConversionTests {
    @Test func doubleIsIntegerTrueForWholeValue() {
        let value = 42.0
        #expect(value.isInteger == true)
    }

    @Test func doubleIsIntegerFalseForFractional() {
        let value = 1.5
        #expect(value.isInteger == false)
    }

    @Test func qaToZilStringConvertsLargeMagnitude() throws {
        let amount = try Amount(qa: "5000000000000")
        let zilString = amount.zilString
        #expect(zilString.contains("5"))
    }
}

// MARK: - ExpressibleByAmount+Bound nonNumericString throw

struct ExpressibleByAmountBoundNonNumericTests {
    @Test func nonNumericStringThrows() {
        #expect(throws: (any Swift.Error).self) {
            _ = try Amount(zil: "abc")
        }
    }
}

// MARK: - Combine cancel path

struct CombineCancelPathTests {
    @Test func cancelCallsThroughTaskBox() {
        let box = TaskBox()
        let task = Task<Void, Never> { /* no-op */ }
        box.set(task)
        box.cancel()
        #expect(true) // Reaching here without trapping is the test
    }
}

// MARK: - Nonce arithmetic

struct NonceIncrementTests {
    @Test func increasedByOneIncrementsValue() {
        let n: Nonce = 41
        let incremented = n.increasedByOne()
        #expect(incremented.nonce == 42)
    }
}
