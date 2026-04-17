//
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
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
    func toKeypair(encryptedBy password: String) throws -> KeyPair {
        try KeyPair(private: decryptPrivateKey(encryptedBy: password))
    }

    func decryptPrivateKey(encryptedBy password: String) throws -> PrivateKey {
        guard password.count >= Keystore.minimumPasswordLength else {
            throw Zesame.Error.keystorePasswordTooShort(
                provided: password.count,
                minimum: Keystore.minimumPasswordLength
            )
        }

        let derivedKey = try deriveKey(password: password)
        let symmetricKey = SymmetricKey(data: derivedKey.data)

        do {
            let gcmNonce = try AES.GCM.Nonce(data: crypto.cipherParameters.nonce)
            let sealedBox = try AES.GCM.SealedBox(
                nonce: gcmNonce,
                ciphertext: crypto.encryptedPrivateKey,
                tag: crypto.cipherParameters.tag
            )
            let plaintext = try AES.GCM.open(sealedBox, using: symmetricKey)
            guard let privateKey = try? PrivateKey(rawRepresentation: plaintext) else {
                throw Zesame.Error.walletImport(.badPrivateKeyHex)
            }
            return privateKey
        } catch let error as Zesame.Error {
            throw error
        } catch {
            throw Zesame.Error.walletImport(.incorrectPassword)
        }
    }
}

public extension Keystore.Crypto {
    init(
        derivedKey: DerivedKey,
        privateKey: PrivateKey,
        kdf: KDF,
        parameters: KDFParams
    ) throws {
        let symmetricKey = SymmetricKey(data: derivedKey.data)
        let sealedBox = try AES.GCM.seal(privateKey.rawRepresentation, using: symmetricKey)
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
