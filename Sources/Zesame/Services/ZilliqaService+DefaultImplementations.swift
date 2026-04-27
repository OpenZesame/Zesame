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

    /// Default implementation of the protocol requirement: re-encrypts non-default-KDF keystores
    /// to the default KDF. Forwards to ``restoreWallet(from:reencryptToDefaultKDF:)`` with
    /// `reencryptToDefaultKDF: true`.
    func restoreWallet(from restoration: KeyRestoration) async throws -> Wallet {
        try await restoreWallet(from: restoration, reencryptToDefaultKDF: true)
    }

    /// Materialises a wallet from a ``KeyRestoration``.
    ///
    /// `reencryptToDefaultKDF` is reserved for forward-compatibility: when a second `KDF` case
    /// is introduced, an imported keystore using the non-default variant will be transparently
    /// re-encrypted with the default. With only `.pbkdf2` in the enum today the parameter has
    /// no observable effect. Tests pass `false` (or omit it) to keep the contract stable.
    func restoreWallet(
        from restoration: KeyRestoration,
        reencryptToDefaultKDF _: Bool
    ) async throws -> Wallet {
        switch restoration {
        case let .keystore(keystore, _):
            return Wallet(keystore: keystore)
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
