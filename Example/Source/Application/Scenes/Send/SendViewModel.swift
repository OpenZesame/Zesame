//
//  SendViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ZilliqaSDK

public extension ObservableType {

    func catchErrorReturnEmpty() -> Observable<E> {
        return catchError { _ in
            return Observable.empty()
        }
    }

    func asDriverOnErrorReturnEmpty() -> Driver<E> {
        return asDriver { _ in
            return Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

//extension Reactive where Base: ZilliqaService {
//    func getBalance() -> Driver<Double> {
//        return Single.create { single in
//            self.base.getBalalance() {
//                single(.success($0.balance))
//            }
//
////            guard success else {
////                completable(.error(CacheError.failedCaching))
////                return Disposables.create {}
////            }
////
////
//            return Disposables.create {}
//        }.asObservable().asDriverOnErrorReturnEmpty()
//    }
//}

extension DefaultZilliqaService {
    func getBalance() -> Driver<String> {
        return Single.create { [weak self] single in
            self?.getBalalance() {
                single(.success($0.balance))
            }

            //            guard success else {
            //                completable(.error(CacheError.failedCaching))
            //                return Disposables.create {}
            //            }
            //
            //
            return Disposables.create {}
            }.asObservable().asDriverOnErrorReturnEmpty()
    }
}

struct SendViewModel {
    private let bag = DisposeBag()
    
    typealias NavigationTo = Navigation<SendNavigator>
    private let navigateTo: NavigationTo
    private let wallet: Wallet
    private let zilliqaService: DefaultZilliqaService

    init(_ navigation: @escaping NavigationTo, wallet: Wallet) {
        self.navigateTo = navigation
        self.wallet = wallet
        self.zilliqaService = DefaultZilliqaService(wallet: wallet)
    }
}

extension SendViewModel: ViewModelled {
    struct Input {
        let sendTrigger: Driver<Void>
    }
    struct Output {
        let address: Driver<String>
        let balance: Driver<String>
    }
    func transform(input: Input) -> Output {

        let wallet = Driver.just(self.wallet)

//        let balance = Driver<String>.deferred { () -> SharedSequence<DriverSharingStrategy, String> in
//            <#code#>
//        }

        let balance = zilliqaService.getBalance().map { "\($0) ZILs" }

        return Output(
            address: wallet.map { $0.address.address },
            balance: balance//wallet.map { String(describing: $0.balance.amount) }
        )
    }
}
