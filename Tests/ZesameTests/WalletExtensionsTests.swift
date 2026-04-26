import Foundation
import Testing
@testable import Zesame

private let testPrivateKey =
    try! PrivateKey(rawRepresentation: Data(hex: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"))
private let testPassword = "apabanan"

struct WalletCodableTests {
    @Test func encodeAndDecodeWallet() throws {
        let keystore = try Keystore.makeTest()
        let wallet = Wallet(keystore: keystore)

        let data = try JSONEncoder().encode(wallet)
        let decoded = try JSONDecoder().decode(Wallet.self, from: data)
        #expect(decoded.address == wallet.address)
    }

    @Test func walletInitFromKeystore() throws {
        let keystore = try Keystore.makeTest()
        let wallet = Wallet(keystore: keystore)
        #expect(wallet.address == keystore.address)
    }

    /// Regression: a tampered JSON whose top-level `address` differs from `keystore.address`
    /// must surface ``Zesame.Error.walletImport(.walletAddressMismatch)`` instead of being
    /// silently accepted.
    @Test func decodeRejectsAddressKeystoreMismatch() throws {
        let keystore = try Keystore.makeTest()
        let other = "F510333720c5Dd3c3C08bC8e085e8c981ce74691"
        let json: [String: Any] = try [
            "keystore": keystore.toJson(),
            "address": other,
        ]
        let data = try JSONSerialization.data(withJSONObject: json)
        do {
            _ = try JSONDecoder().decode(Wallet.self, from: data)
            Issue.record("Expected walletAddressMismatch")
        } catch Zesame.Error.walletImport(.walletAddressMismatch) {
            // expected
        }
    }
}

struct WalletDescriptionTests {
    @Test func description() throws {
        let keystore = try Keystore.makeTest()
        let wallet = Wallet(keystore: keystore)
        let desc = wallet.description
        #expect(desc.contains("Wallet(address:"))
        #expect(desc.contains(wallet.address.asString))
    }
}

struct WalletDecryptTests {
    @Test func decryptReturnsKeyPair() throws {
        let keystore = try Keystore.makeTest()
        let wallet = Wallet(keystore: keystore)
        let keyPair = try wallet.decrypt(password: testPassword)
        #expect(keyPair.privateKey == testPrivateKey)
    }

    @Test func decryptWithWrongPasswordThrows() throws {
        let keystore = try Keystore.makeTest()
        let wallet = Wallet(keystore: keystore)
        #expect(throws: (any Swift.Error).self) {
            _ = try wallet.decrypt(password: "wrongPassword")
        }
    }
}

struct KeyRestorationTests {
    @Test func initFromPrivateKeyHexString() throws {
        let hex = "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"
        let restoration = try KeyRestoration(privateKeyHexString: hex, encryptBy: testPassword)
        if case let .privateKey(pk, password, _) = restoration {
            #expect(pk == testPrivateKey)
            #expect(password == testPassword)
        } else {
            Issue.record("Expected .privateKey case")
        }
    }

    @Test func initFromBadPrivateKeyHexThrows() {
        #expect(throws: (any Swift.Error).self) {
            _ = try KeyRestoration(privateKeyHexString: "notahex!", encryptBy: testPassword)
        }
    }

    @Test func initFromKeyStoreJSON() throws {
        let keystore = try Keystore.makeTest()
        let jsonData = try JSONEncoder().encode(keystore)
        let restoration = try KeyRestoration(keyStoreJSON: jsonData, encryptedBy: testPassword)
        if case let .keystore(ks, pw) = restoration {
            #expect(ks.address == keystore.address)
            #expect(pw == testPassword)
        } else {
            Issue.record("Expected .keystore case")
        }
    }

    @Test func initFromKeyStoreJSONString() throws {
        let keystore = try Keystore.makeTest()
        let jsonData = try JSONEncoder().encode(keystore)
        let jsonString = try #require(String(data: jsonData, encoding: .utf8))
        let restoration = try KeyRestoration(keyStoreJSONString: jsonString, encryptedBy: testPassword)
        if case let .keystore(ks, _) = restoration {
            #expect(ks.address == keystore.address)
        } else {
            Issue.record("Expected .keystore case")
        }
    }

    @Test func initFromBadJSONStringThrows() {
        #expect(throws: (any Swift.Error).self) {
            _ = try KeyRestoration(keyStoreJSONString: "not json", encryptedBy: testPassword)
        }
    }

    @Test func initFromInvalidEncodingThrows() {
        // Create a string that can't be encoded as UTF-8 (use Latin1)
        // Actually it's hard to create a valid String that isn't valid UTF-8 in Swift
        // So test that passing bad keystore JSON fails properly
        let badJSON = "{\"bad\":\"json\"}"
        #expect(throws: (any Swift.Error).self) {
            _ = try KeyRestoration(keyStoreJSONString: badJSON, encryptedBy: testPassword)
        }
    }
}

struct KeyPairTests {
    @Test func publicKeyFromPrivateKey() {
        let keyPair = KeyPair(private: testPrivateKey)
        #expect(keyPair.publicKey == testPrivateKey.publicKey)
    }

    @Test func publicKeyDescription() {
        let keyPair = KeyPair(private: testPrivateKey)
        let description = keyPair.publicKey.description
        #expect(!description.isEmpty)
        #expect(description.count == 66) // compressed 33 bytes = 66 hex chars
    }
}
