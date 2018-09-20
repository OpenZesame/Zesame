//
//  DefaultZilliqaService.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-09-10.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxSwift
import JSONRPCKit
import APIKit

public typealias ZilliqaServiceReactive = ZilliqaService & ReactiveCompatible

public final class DefaultZilliqaService: ZilliqaServiceReactive {

    public let wallet: Wallet

    public let apiClient: APIClient = DefaultAPIClient()

    public init(wallet: Wallet) {
        self.wallet = wallet
    }
}

public extension DefaultZilliqaService {
    func getBalalance(done: @escaping RequestDone<BalanceResponse>) -> Void {
        return apiClient.send(request: BalanceRequest(publicAddress: wallet.address.address), done: done)
    }


    func send(transaction: Transaction, done: @escaping RequestDone<TransactionIdentifier>) {
        return apiClient.send(request: TransactionRequest(transaction: transaction), done: done)
    }
}
