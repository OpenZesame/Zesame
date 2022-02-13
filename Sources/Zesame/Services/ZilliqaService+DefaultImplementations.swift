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

import Foundation

import EllipticCurveKit

var isRunningTests: Bool {
    return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}


public extension ZilliqaService {

    func verifyThat(
        encryptionPassword: String,
        canDecryptKeystore keystore: Keystore
    ) async throws -> Bool {
        do {
           _ = try await keystore.decryptPrivateKeyWith(password: encryptionPassword)
            return true
        } catch {
            return false
        }
    }

    func createNewWallet(
        encryptionPassword: String,
        kdf: KDF = .default
    ) async throws -> Wallet {
        let privateKey = PrivateKey.generateNew()
        let keyRestoration: KeyRestoration = .privateKey(privateKey, encryptBy: encryptionPassword, kdf: kdf)
        return try await restoreWallet(from: keyRestoration)
    }

    func restoreWallet(from restoration: KeyRestoration) async throws -> Wallet {
        switch restoration {
        case .keystore(let keystore, let password):
            let privateKey = try await keystore.decryptPrivateKeyWith(password: password)
            
            // We would like the SDK to always store Keystore on same format, so disregarding if we imported a keystore having KDF `pbkdf2` or `scrypt`, the stored KDF in the users wallet
            // is the same, so that decrypting takes ~same time for every user.
            if keystore.crypto.kdf == KDF.default || isRunningTests {
                return Wallet(keystore: keystore)
            } else {
                let defaultKeyRestoration: KeyRestoration = .privateKey(privateKey, encryptBy: password, kdf: .default)
                return try await restoreWallet(from: defaultKeyRestoration)
            }
            
        case .privateKey(let privateKey, let newPassword, let kdf):
            do {
                let keystore = try await Keystore.from(privateKey: privateKey, encryptBy: newPassword, kdf: kdf)
                
                return Wallet(keystore: keystore)
            } catch {
                throw Error.walletImport(.keystoreError(error))
            }
        }
    }
    
    func exportKeystore(privateKey: PrivateKey, encryptWalletBy password: String) async throws -> Keystore {
        try await exportKeystore(privateKey: privateKey, encryptWalletBy: password)
    }

    func exportKeystore(
        privateKey: PrivateKey,
        encryptWalletBy password: String,
        kdf: KDF = .default
    ) async throws -> Keystore {
        do {
            return try await Keystore.from(
                privateKey: privateKey,
                encryptBy: password,
                kdf: kdf
            )
        } catch {
            throw Error.keystoreExport(error)
        }
        
    }
}
