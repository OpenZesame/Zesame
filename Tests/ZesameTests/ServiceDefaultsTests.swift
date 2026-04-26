import Combine
import CryptoKit
import Foundation
import Testing
@testable import Zesame

private let testPrivKey =
    try! PrivateKey(rawRepresentation: Data(hex: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"))
private let testPass = "apabanan"

// MARK: - Mock API Client

private enum MockError: Swift.Error { case typeMismatch }

private struct MockAPIClient: APIClient {
    let handler: @Sendable (String) async throws -> any Decodable

    func send<Response: Decodable>(method: RPCMethod<Response>) async throws -> Response {
        let result = try await handler(method.name)
        guard let typed = result as? Response else {
            throw Zesame.Error.api(.request(MockError.typeMismatch))
        }
        return typed
    }
}

// MARK: - Service default implementation tests

struct ZilliqaServiceDefaultsTests {
    private let service = DefaultZilliqaService(endpoint: .testnet)

    @Test func verifyCorrectPassword() async throws {
        let keystore = try Keystore.makeTest()
        let result = try await service.verifyThat(encryptionPassword: testPass, canDecryptKeystore: keystore)
        #expect(result == true)
    }

    @Test func verifyWrongPassword() async throws {
        let keystore = try Keystore.makeTest()
        let result = try await service.verifyThat(encryptionPassword: "wrongPass!", canDecryptKeystore: keystore)
        #expect(result == false)
    }

    @Test func exportKeystore() async throws {
        let keystore = try await service.exportKeystore(
            privateKey: testPrivKey,
            encryptWalletBy: testPass,
            kdf: .pbkdf2
        )
        let decrypted = try keystore.decryptPrivateKey(encryptedBy: testPass)
        #expect(decrypted == testPrivKey)
    }

    @Test func createNewWallet() async throws {
        let wallet = try await service.createNewWallet(encryptionPassword: testPass, kdf: .pbkdf2)
        #expect(!wallet.address.asString.isEmpty)
    }

    @Test func restoreWalletFromPrivateKey() async throws {
        let restoration = KeyRestoration.privateKey(testPrivKey, encryptBy: testPass, kdf: .pbkdf2)
        let wallet = try await service.restoreWallet(from: restoration)
        let keyPair = try wallet.decrypt(password: testPass)
        #expect(keyPair.privateKey == testPrivKey)
    }

    @Test func restoreWalletFromKeystore() async throws {
        let keystore = try Keystore.makeTest()
        let restoration = KeyRestoration.keystore(keystore, password: testPass)
        let wallet = try await service.restoreWallet(from: restoration)
        #expect(wallet.address == keystore.address)
    }
}

// MARK: - Signing tests

struct ZilliqaServiceSigningTests {
    private let service = DefaultZilliqaService(endpoint: .testnet)

    @Test func signMessage() throws {
        let keyPair = KeyPair(private: testPrivKey)
        let messageData = Data(repeating: 0xAB, count: 32)
        let signature = try service.sign(message: messageData, using: keyPair)
        #expect(keyPair.publicKey.isValidSignature(signature, hashed: messageData))
    }

    @Test func signPayment() throws {
        let keyPair = KeyPair(private: testPrivKey)
        let recipient = try LegacyAddress(string: "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039")
        let payment = Payment.withMinimumGasLimit(
            to: recipient,
            amount: 1,
            gasPrice: GasPrice.min,
            nonce: 0
        )
        let signed = try service.sign(payment: payment, using: keyPair, network: .mainnet)
        let data = try JSONEncoder().encode(signed)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let sig = json["signature"] as? String
        #expect(sig?.count == 128)
    }
}

// MARK: - ZilliqaServiceReactive default implementations

struct ZilliqaServiceReactiveDefaultsTests {
    private let service = DefaultZilliqaService(endpoint: .testnet)

    @Test func extractKeyPairFromKeystore() async throws {
        let keystore = try Keystore.makeTest()
        let keyPair: KeyPair = try await withCheckedThrowingContinuation { cont in
            var cancellable: AnyCancellable?
            cancellable = service.combine.extractKeyPairFrom(keystore: keystore, encryptedBy: testPass)
                .sink(receiveCompletion: { completion in
                    if case let .failure(e) = completion { cont.resume(throwing: e) }
                    _ = cancellable
                }, receiveValue: { kp in
                    cont.resume(returning: kp)
                    _ = cancellable
                })
        }
        #expect(keyPair.privateKey == testPrivKey)
    }

    @Test func extractKeyPairFromWallet() async throws {
        let keystore = try Keystore.makeTest()
        let wallet = Wallet(keystore: keystore)
        let keyPair: KeyPair = try await withCheckedThrowingContinuation { cont in
            var cancellable: AnyCancellable?
            cancellable = service.combine.extractKeyPairFrom(wallet: wallet, encryptedBy: testPass)
                .sink(receiveCompletion: { completion in
                    if case let .failure(e) = completion { cont.resume(throwing: e) }
                    _ = cancellable
                }, receiveValue: { kp in
                    cont.resume(returning: kp)
                    _ = cancellable
                })
        }
        #expect(keyPair.privateKey == testPrivKey)
    }

    @Test func extractKeyPairFromKeystoreWithWrongPasswordFails() async throws {
        let keystore = try Keystore.makeTest()
        var didFail = false
        do {
            let _: KeyPair = try await withCheckedThrowingContinuation { cont in
                var cancellable: AnyCancellable?
                cancellable = service.combine.extractKeyPairFrom(
                    keystore: keystore, encryptedBy: "wrongPassword!"
                )
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(e) = completion { cont.resume(throwing: e) }
                        _ = cancellable
                    },
                    receiveValue: { kp in cont.resume(returning: kp); _ = cancellable }
                )
            }
        } catch {
            didFail = true
        }
        #expect(didFail)
    }
}

// MARK: - CombineWrapper tests

struct CombineWrapperTests {
    private let service = DefaultZilliqaService(endpoint: .testnet)

    @Test func combineWrapperAccess() {
        let wrapper = service.combine
        #expect(wrapper.base === service)
    }

    @Test func createNewWalletViaCombine() async throws {
        let wallet: Wallet = try await withCheckedThrowingContinuation { cont in
            var cancellable: AnyCancellable?
            cancellable = service.combine.createNewWallet(encryptionPassword: testPass, kdf: .pbkdf2)
                .sink(receiveCompletion: { completion in
                    if case let .failure(e) = completion { cont.resume(throwing: e) }
                    _ = cancellable
                }, receiveValue: { w in
                    cont.resume(returning: w)
                    _ = cancellable
                })
        }
        #expect(!wallet.address.asString.isEmpty)
    }

    @Test func verifyViaCombine() async throws {
        let keystore = try Keystore.makeTest()
        let result: Bool = try await withCheckedThrowingContinuation { cont in
            var cancellable: AnyCancellable?
            cancellable = service.combine.verifyThat(encryptionPassword: testPass, canDecryptKeystore: keystore)
                .sink(receiveCompletion: { completion in
                    if case let .failure(e) = completion { cont.resume(throwing: e) }
                    _ = cancellable
                }, receiveValue: { v in
                    cont.resume(returning: v)
                    _ = cancellable
                })
        }
        #expect(result == true)
    }

    @Test func exportKeystoreViaCombine() async throws {
        let keystore: Keystore = try await withCheckedThrowingContinuation { cont in
            var cancellable: AnyCancellable?
            cancellable = service.combine.exportKeystore(privateKey: testPrivKey, encryptWalletBy: testPass)
                .sink(receiveCompletion: { completion in
                    if case let .failure(e) = completion { cont.resume(throwing: e) }
                    _ = cancellable
                }, receiveValue: { ks in
                    cont.resume(returning: ks)
                    _ = cancellable
                })
        }
        let decrypted = try keystore.decryptPrivateKey(encryptedBy: testPass)
        #expect(decrypted == testPrivKey)
    }

    @Test func restoreWalletViaCombine() async throws {
        let restoration = KeyRestoration.privateKey(testPrivKey, encryptBy: testPass, kdf: .pbkdf2)
        let wallet: Wallet = try await withCheckedThrowingContinuation { cont in
            var cancellable: AnyCancellable?
            cancellable = service.combine.restoreWallet(from: restoration)
                .sink(receiveCompletion: { completion in
                    if case let .failure(e) = completion { cont.resume(throwing: e) }
                    _ = cancellable
                }, receiveValue: { w in
                    cont.resume(returning: w)
                    _ = cancellable
                })
        }
        #expect(!wallet.address.asString.isEmpty)
    }

    @Test func createNewWalletWithShortPasswordFailsViaCombine() async throws {
        var didFail = false
        do {
            let _: Wallet = try await withCheckedThrowingContinuation { cont in
                var cancellable: AnyCancellable?
                cancellable = service.combine.createNewWallet(
                    encryptionPassword: "short!", kdf: .pbkdf2
                )
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(e) = completion { cont.resume(throwing: e) }
                        _ = cancellable
                    },
                    receiveValue: { w in cont.resume(returning: w); _ = cancellable }
                )
            }
        } catch {
            didFail = true
        }
        #expect(didFail)
    }
}
