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

public extension Reactive where Base: (ZilliqaService & AnyObject) {
    func getBalance() -> Driver<BalanceResponse> {
        return Single.create { [weak base] single in
            base?.getBalalance() {
                switch $0 {
                case .failure(let error): single(.error(error))
                case .success(let balance): single(.success(balance))
                }
            }
            return Disposables.create {}
        }.asObservable().asDriverOnErrorReturnEmpty()
    }
}

public extension DefaultZilliqaService {
    func getBalance() -> Driver<BalanceResponse> {
        return Single.create { [weak self] single in
            self?.getBalalance() {
                switch $0 {
                case .failure(let error): single(.error(error))
                case .success(let balance): single(.success(balance))
                }
            }
            return Disposables.create {}
        }.asObservable().asDriverOnErrorReturnEmpty()
    }
}
