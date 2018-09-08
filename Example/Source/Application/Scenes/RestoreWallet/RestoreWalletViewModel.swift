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

        let wallet: Driver<Wallet> = input.privateKey
            .map { KeyPair(privateKeyHex: $0) }
            .filterNil()
            .map { Wallet(keyPair: $0) }

        let restoredWallet: Driver<Wallet> = input.restoreTrigger.withLatestFrom(wallet)
            .do(onNext: { [navigator] in navigator.toHome($0) })

        return Output(
            restoredWallet: restoredWallet
        )
    }
}
