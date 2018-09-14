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
        return Single.create { [weak base] single in
            base?.getBalalance() {
                switch $0 {
                case .failure(let error): single(.error(error))
                case .success(let result): single(.success(result))
                }
            }
            return Disposables.create {}
        }.asObservable()
    }

    func signAndMakeTransaction(payment: Payment, using keyPair: KeyPair) -> Observable<TransactionIdentifier> {
        return Single.create { [weak base] single in
            base?.signAndMakeTransaction(payment: payment, using: keyPair) {
                switch $0 {
                case .failure(let error): single(.error(error))
                case .success(let result): single(.success(result))
                }
            }
            return Disposables.create {}
        }.asObservable()
    }

}
