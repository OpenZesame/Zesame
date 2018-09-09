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
    private let bag = DisposeBag()
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
        let wallet: Driver<Wallet>
    }

    func transform(input: Input) -> Output {

        let wallet: Driver<Wallet> = input.privateKey
            .map { Wallet(privateKeyHex: $0) }
            .filterNil()

        input.restoreTrigger.withLatestFrom(wallet)
            .do(onNext: { [weak navigator] in navigator?.toHome($0) })
            .drive().disposed(by: bag)

        return Output(wallet: wallet)
    }
}
