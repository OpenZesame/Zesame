//
//  ZilliqaService.swift
//  ZilliqaSDK iOS
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import EllipticCurveKit
import JSONRPCKit
import Result
import APIKit
import RxCocoa
import RxSwift
import CryptoSwift

public protocol ZilliqaService {
    var apiClient: APIClient { get }

    func createNewWallet(done: @escaping Done<Wallet>)
    func exportKeystoreJson(from wallet: Wallet, passphrase: String, done: @escaping Done<Keystore>)

    func getBalalance(for address: Address, done: @escaping Done<BalanceResponse>)
    func send(transaction: Transaction, done: @escaping Done<TransactionIdentifier>)
}

public protocol ZilliqaServiceReactive {
    func createNewWallet() -> Observable<Wallet>
    func getBalance(for address: Address) -> Observable<BalanceResponse>
    func sendTransaction(for payment: Payment, signWith keyPair: KeyPair) -> Observable<TransactionIdentifier>
}
