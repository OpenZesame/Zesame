//
//  Rx+ZilliqaService.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-09-10.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import JSONRPCKit
import APIKit
import Result

public extension Reactive where Base: (ZilliqaService & AnyObject) {

    func getBalance() -> Observable<BalanceResponse> {
        return callBase {
            $0.getBalalance(done: $1)
        }
    }

    func sendTransaction(for payment: Payment, signWith keyPair: KeyPair) -> Observable<TransactionIdentifier> {
        return callBase {
            $0.sendTransaction(for: payment, signWith: keyPair, done: $1)
        }
    }

    private func callBase<R>(call: @escaping (Base, @escaping RequestDone<R>) -> Void) -> Observable<R> {
        return Single.create { [weak base] single in
            guard let strongBase = base else { return Disposables.create {} }
            call(strongBase, {
                switch $0 {
                case .failure(let error):
                    print("⚠️ API request failed, error: '\(error)'")
                    single(.error(error))
                case .success(let result):
                    print("🎉 API request successful, response: '\(String(describing: result))'")
                    single(.success(result))
                }
            })
            return Disposables.create {}
        }.asObservable()
    }
}
