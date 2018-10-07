//
//  ZilliqaService.swift
//  Zesame iOS
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import EllipticCurveKit
import JSONRPCKit
import Result
import APIKit
import RxSwift
import CryptoSwift

public extension Wallet {
    func decrypt(passphrase: String, done: @escaping Done<KeyPair>) {
        keystore.toKeypair(encryptedBy: passphrase, done: done)
    }
}

public protocol ZilliqaService {
    var apiClient: APIClient { get }

    func createNewWallet(encryptionPassphrase: String, done: @escaping Done<Wallet>)
    func exportKeystore(address: Address, privateKey: PrivateKey, encryptWalletBy passphrase: String, done: @escaping Done<Keystore>)
    func importWalletFrom(keyStore: Keystore, encryptedBy passphrase: String, done: @escaping Done<Wallet>)
    func importWalletFrom(privateKeyHex: HexString, newEncryptionPassphrase: String, done: @escaping Done<Wallet>)
    func getBalalance(for address: Address, done: @escaping Done<BalanceResponse>)
    func send(transaction: Transaction, done: @escaping Done<TransactionIdentifier>)
}

//public extension ZilliqaService {
//    func exportKeystore(from wallet: Wallet, encryptWalletBy passphrase: String, done: @escaping Done<Keystore>) {
//        exportKeystore(address: wallet.address, privateKey: wallet.keyPair.privateKey, encryptWalletBy: passphrase, done: done)
//    }
//}

public protocol ZilliqaServiceReactive {
    func createNewWallet(encryptionPassphrase: String) -> Observable<Wallet>

    func exportKeystore(address: Address, privateKey: PrivateKey, encryptWalletBy passphrase: String) -> Observable<Keystore>
    func importWalletFrom(keyStore: Keystore, encryptedBy passphrase: String) -> Observable<Wallet>
    func importWalletFrom(privateKeyHex: HexString, newEncryptionPassphrase: String) -> Observable<Wallet>

    func getBalance(for address: Address) -> Observable<BalanceResponse>
    func sendTransaction(for payment: Payment, keystore: Keystore, passphrase: String) -> Observable<TransactionIdentifier>
    func sendTransaction(for payment: Payment, signWith keyPair: KeyPair) -> Observable<TransactionIdentifier>
}

//public extension ZilliqaServiceReactive {
//    func exportKeystore(from wallet: Wallet, encryptWalletBy passphrase: String) -> Observable<Keystore> {
//        return exportKeystore(address: wallet.address, privateKey: wallet.keyPair.privateKey, encryptWalletBy: passphrase)
//    }
//}
