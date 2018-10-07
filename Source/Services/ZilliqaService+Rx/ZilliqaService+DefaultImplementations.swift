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

    func createNewWallet(done: @escaping Done<Wallet>) {
        background {
            let newWallet = Wallet(keyPair: KeyPair(private: PrivateKey.generateNew()), network: Network.testnet)
            main {
                done(Result.success(newWallet))
            }
        }
    }

    func exportKeystore(address: Address, privateKey: PrivateKey, encryptWalletBy passphrase: String, done: @escaping Done<Keystore>) {
        Keystore.from(address: address, privateKey: privateKey, encryptBy: passphrase, done: done)
    }

    func importWalletFrom(keyStore: Keystore, encryptedBy passphrase: String, done: @escaping Done<Wallet>) {
        keyStore.toWallet(encryptedBy: passphrase, done: done)
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
