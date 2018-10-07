//
//  ZilliqaService+DefaultImplementations.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-09-23.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import Result
import EllipticCurveKit
import CryptoSwift

public extension ZilliqaService {

    func createNewWallet(encryptionPassphrase: String, done: @escaping Done<Wallet>) {
//        background {
//            let privateKey = PrivateKey.generateNew()
//            let keyPair = KeyPair(private: privateKey)
//            let address = Address(keyPair: keyPair, network: Network.default)
//            Keystore.from(address: address, privateKey: privateKey, encryptBy: encryptionPassphrase) {
//                guard case .success(let keystore) = $0 else { done(Result.failure($0.error!)); return }
//                let wallet = Wallet(keystore: keystore, address: address)
//                main {
//                    done(Result.success(wallet))
//                }
//            }
//        }

        background {
            let privateKey = PrivateKey.generateNew()
            self.importWalletFrom(privateKey: privateKey, newEncryptionPassphrase: encryptionPassphrase, done: done)
        }
    }

    func exportKeystore(address: Address, privateKey: PrivateKey, encryptWalletBy passphrase: String, done: @escaping Done<Keystore>) {
        Keystore.from(address: address, privateKey: privateKey, encryptBy: passphrase, done: done)
    }

    func importWalletFrom(privateKeyHex: HexString, newEncryptionPassphrase: String, done: @escaping Done<Wallet>) {
        background {
            guard let keyPair = KeyPair(privateKeyHex: privateKeyHex) else {
                main {
                    done(.failure(.walletImport(.badPrivateKeyHex)))
                }
                return
            }
            self.importWalletFrom(privateKey: keyPair.privateKey, newEncryptionPassphrase: newEncryptionPassphrase, done: done)
        }
    }

    func importWalletFrom(privateKey: PrivateKey, newEncryptionPassphrase: String, done: @escaping Done<Wallet>) {
        background {
            let address = Address(privateKey: privateKey)
            Keystore.from(address: address, privateKey: privateKey, encryptBy: newEncryptionPassphrase) {
                guard case .success(let keystore) = $0 else { done(Result.failure($0.error!)); return }
                let wallet = Wallet(keystore: keystore, address: address)
                main {
                    done(Result.success(wallet))
                }
            }
        }
    }

    func importWalletFrom(keyStore: Keystore, encryptedBy passphrase: String, done: @escaping Done<Wallet>) {
        guard let address = Address(uncheckedString: keyStore.address) else {
            done(.failure(.walletImport(.badAddress)))
            return
        }
        let wallet = Wallet(keystore: keyStore, address: address)
        done(.success(wallet))
    }
}

// MARK: - Wallet Import + JSON support
public extension ZilliqaService {
    func importWalletFrom(keyStoreJSON: Data, encryptedBy passphrase: String, done: @escaping Done<Wallet>) {
        do {
            let keyStore = try JSONDecoder().decode(Keystore.self, from: keyStoreJSON)
            importWalletFrom(keyStore: keyStore, encryptedBy: passphrase, done: done)
        } catch let error as Swift.DecodingError {
            done(Result.failure(Error.walletImport(.jsonDecoding(error))))
        } catch { fatalError("incorrect implementation") }
    }

    func importWalletFrom(keyStoreJSONString: String, encodedBy encoding: String.Encoding = .utf8, encryptedBy passphrase: String, done: @escaping Done<Wallet>) {
        guard let json = keyStoreJSONString.data(using: encoding) else { done(.failure(.walletImport(.jsonStringDecoding))); return }
        importWalletFrom(keyStoreJSON: json, encryptedBy: passphrase, done: done)
    }
}
