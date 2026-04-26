//
// MIT License
//
// Copyright (c) 2018-2026 Open Zesame (https://github.com/OpenZesame)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

/// `true` when running under XCTest. Used to avoid the slow scrypt re-encryption pass during
/// keystore imports in tests.
var isRunningTests: Bool {
    ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

public extension ZilliqaService {
    /// Default verification: attempts a full keystore decrypt and reports success/failure.
    func verifyThat(
        encryptionPassword: String,
        canDecryptKeystore keystore: Keystore
    ) async throws -> Bool {
        do {
            _ = try keystore.decryptPrivateKey(encryptedBy: encryptionPassword)
            return true
        } catch {
            return false
        }
    }

    /// Generates a fresh secp256k1 ``PrivateKey`` and immediately wraps it in a keystore.
    func createNewWallet(
        encryptionPassword: String,
        kdf: KDF = .default
    ) async throws -> Wallet {
        let privateKey = PrivateKey()
        return try await restoreWallet(from: .privateKey(privateKey, encryptBy: encryptionPassword, kdf: kdf))
    }

    /// Materialises a wallet from a ``KeyRestoration``.
    ///
    /// When importing an existing keystore that uses a non-default KDF, the keystore is silently
    /// re-encrypted with the default KDF — except in tests, where the slow scrypt round-trip is
    /// skipped via ``isRunningTests``.
    func restoreWallet(from restoration: KeyRestoration) async throws -> Wallet {
        switch restoration {
        case let .keystore(keystore, password):
            let privateKey = try keystore.decryptPrivateKey(encryptedBy: password)
            if keystore.crypto.kdf == KDF.default || isRunningTests {
                return Wallet(keystore: keystore)
            } else {
                return try await restoreWallet(from: .privateKey(privateKey, encryptBy: password, kdf: .default))
            }
        case let .privateKey(privateKey, newPassword, kdf):
            let keystore = try Keystore.from(privateKey: privateKey, encryptBy: newPassword, kdf: kdf)
            return Wallet(keystore: keystore)
        }
    }

    /// Encrypts `privateKey` into a fresh ``Keystore`` using `password` and `kdf`.
    func exportKeystore(
        privateKey: PrivateKey,
        encryptWalletBy password: String,
        kdf: KDF = .default
    ) async throws -> Keystore {
        try Keystore.from(privateKey: privateKey, encryptBy: password, kdf: kdf)
    }
}
