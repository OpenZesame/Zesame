//
//  OpenWalletViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import RxCocoa

public struct OpenWalletViewModel {
    private let navigator: OpenWalletNavigator
    public init(navigator: OpenWalletNavigator) {
        self.navigator = navigator
    }
}

extension OpenWalletViewModel: ViewModelled {}
public extension OpenWalletViewModel {

    struct Input {
        let createNewTrigger: Driver<Void>
        let restoreTrigger: Driver<Void>
    }

    struct Output {
        let createNew: Driver<Void>
        let restore: Driver<Void>
    }

    func transform(input: Input) -> Output {
        let createNewWallet = input.createNewTrigger.do(onNext: { [navigator] in
            navigator.toCreateNewWallet()
        })

        let restoreWallet = input.restoreTrigger.do(onNext: { [navigator] in
            navigator.toRestoreWallet()
        })

        return Output(createNew: createNewWallet, restore: restoreWallet)
    }
}
