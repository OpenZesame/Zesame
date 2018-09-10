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

    typealias NavigationTo = Navigation<RestoreWalletNavigator>
    private let navigateTo: NavigationTo

    init(_ navigation: @escaping NavigationTo) {
        self.navigateTo = navigation
    }
}

extension RestoreWalletViewModel: ViewModelType {

    struct Input: InputType {
        struct FromView {
            let privateKey: Driver<String>
            let restoreTrigger: Driver<Void>
        }
        let fromView: FromView
        init(fromView: FromView, fromController: NotUsed = nil) {
            self.fromView = fromView
        }
    }

    struct Output {}

    func transform(input: Input) -> Output {

        let wallet = input.fromView.privateKey
            .map { Wallet(privateKeyHex: $0) }
            .filterNil()

        input.fromView.restoreTrigger
            .withLatestFrom(wallet).do(onNext: {
                self.navigateTo(.restored($0))
            }).drive().disposed(by: bag)

        return Output()
    }
}
