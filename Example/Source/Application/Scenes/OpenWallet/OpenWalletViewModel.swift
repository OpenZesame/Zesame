//
//  OpenWalletViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import RxSwift
import RxCocoa

struct OpenWalletViewModel {
    private let bag = DisposeBag()
    private let navigator: OpenWalletNavigator
    init(navigator: OpenWalletNavigator) {
        self.navigator = navigator
    }
}

extension OpenWalletViewModel: ViewModelled {

    struct Input {
        let createNewTrigger: Driver<Void>
        let restoreTrigger: Driver<Void>
    }

    struct Output {}

    func transform(input: Input) -> Output {

        input.createNewTrigger.do(onNext: { [navigator] in
            navigator.toCreateNewWallet()
        }).drive().disposed(by: bag)

        input.restoreTrigger.do(onNext: { [navigator] in
            navigator.toRestoreWallet()
        }).drive().disposed(by: bag)

        return Output()
    }
}
