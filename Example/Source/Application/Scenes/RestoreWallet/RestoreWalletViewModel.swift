//
//  RestoreWalletViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import RxCocoa
import RxSwift
import ZilliqaSDK

struct RestoreWalletViewModel {
    private let navigator: RestoreWalletNavigator
    init(navigator: RestoreWalletNavigator) {
        self.navigator = navigator
    }
}

extension RestoreWalletViewModel: ViewModelled {

    struct Input {
        let privateKey: Driver<String>
        let restoreTrigger: Driver<Void>
    }

    struct Output {
        let restoredWallet: Driver<Wallet>
    }

    func transform(input: Input) -> Output {

        let restoredWallet: Driver<ZilliqaSDK.KeyPair> = input.privateKey.map { ZilliqaSDK.KeyPair(privateKeyHex: $0) }
            .filterNil()
        

        return Output(
            restoredWallet: .empty()
        )
    }
}


protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    var value: Wrapped? {
        return self
    }
}

extension Observable where Element: OptionalType {

    func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .empty()
            }
        }
    }
}

extension SharedSequence where S == DriverSharingStrategy, Element: OptionalType {

    func filterNil() -> Driver<Element.Wrapped> {
        return flatMap { (element) -> Driver<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .empty()
            }
        }
    }
}
