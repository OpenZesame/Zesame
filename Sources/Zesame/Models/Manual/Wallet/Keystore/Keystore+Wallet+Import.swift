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

import CryptoKit
import Foundation

public extension Keystore {
    /// Decrypts the keystore and wraps the result in a ``KeyPair``.
    func toKeypair(encryptedBy password: String) throws -> KeyPair {
        try KeyPair(private: decryptPrivateKey(encryptedBy: password))
    }

    /// Runs the keystore decryption pipeline: KDF, AES-GCM open, raw-key parse.
    ///
    /// - Throws:
    ///   - ``Zesame/Error/keystorePasswordTooShort(provided:minimum:)`` when the password is below
    ///     ``minimumPasswordLength``.
    ///   - ``Zesame/Error/decryptPrivateKey(_:)`` when the AES-GCM nonce/tag are malformed.
    ///   - ``Zesame/Error/walletImport(_:)`` (`.incorrectPassword`) when the AES-GCM tag doesn't
    ///     verify (indistinguishable from "wrong password").
    ///   - ``Zesame/Error/walletImport(_:)`` (`.badPrivateKeyHex`) when the plaintext isn't a
    ///     valid private key (corrupted keystore).
    func decryptPrivateKey(encryptedBy password: String) throws -> PrivateKey {
        guard password.count >= Keystore.minimumPasswordLength else {
            throw Zesame.Error.keystorePasswordTooShort(
                provided: password.count,
                minimum: Keystore.minimumPasswordLength
            )
        }

        let symmetricKey = try deriveKey(password: password)

        let sealedBox: AES.GCM.SealedBox
        do {
            let gcmNonce = try AES.GCM.Nonce(data: crypto.cipherParameters.nonce)
            sealedBox = try AES.GCM.SealedBox(
                nonce: gcmNonce,
                ciphertext: crypto.encryptedPrivateKey,
                tag: crypto.cipherParameters.tag
            )
        } catch {
            // coverage:exclude-start
            // `Keystore.Crypto`'s designated initialiser enforces 12-byte nonce / 16-byte tag /
            // any-length ciphertext, all of which AES.GCM.Nonce + SealedBox accept. Reaching
            // here would require a `Crypto` value that bypassed validation — not possible via
            // public API.
            throw Zesame.Error.decryptPrivateKey(error)
            // coverage:exclude-end
        }
        let plaintext: Data
        do {
            plaintext = try AES.GCM.open(sealedBox, using: symmetricKey)
        } catch {
            throw Zesame.Error.walletImport(.incorrectPassword)
        }
        guard let privateKey = try? PrivateKey(rawRepresentation: plaintext) else {
            throw Zesame.Error.walletImport(.badPrivateKeyHex)
        }
        return privateKey
    }
}

public extension Keystore.Crypto {
    /// Encrypts `privateKey` under `derivedKey` (AES-256-GCM) and packs the ciphertext, nonce,
    /// and tag into a ``Crypto`` payload along with the KDF parameters needed to reverse the
    /// process at decrypt time.
    init(
        derivedKey: SymmetricKey,
        privateKey: PrivateKey,
        kdf: KDF,
        parameters: KDFParams
    ) throws {
        let sealedBox = try AES.GCM.seal(privateKey.rawRepresentation, using: derivedKey)
        let nonce = Data(sealedBox.nonce)
        let tag = sealedBox.tag
        let ciphertext = sealedBox.ciphertext
        try self.init(
            cipherParameters: Keystore.Crypto.CipherParameters(nonce: nonce, tag: tag),
            encryptedPrivateKeyHex: ciphertext.asHex,
            kdf: kdf,
            kdfParams: parameters
        )
    }
}
