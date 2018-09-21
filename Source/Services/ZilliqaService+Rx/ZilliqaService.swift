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

public protocol ZilliqaService {
    var apiClient: APIClient { get }
    func createNewWallet() -> Wallet
    func getBalalance(for address: Address, done: @escaping RequestDone<BalanceResponse>)
    func send(transaction: Transaction, done: @escaping RequestDone<TransactionIdentifier>)
}

public protocol ZilliqaServiceReactive {
    func createNewWallet() -> Observable<Wallet>
    func getBalance(for address: Address) -> Observable<BalanceResponse>
    func sendTransaction(for payment: Payment, signWith keyPair: KeyPair) -> Observable<TransactionIdentifier>
}
