//
//  ChooseWalletViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import RxSwift
import RxCocoa

struct ChooseWalletViewModel {
    private let bag = DisposeBag()

    typealias NavigationTo = Navigation<ChooseWalletNavigator>
    private let navigateTo: NavigationTo

    init(_ navigation: @escaping NavigationTo) {
        self.navigateTo = navigation
    }
}

extension ChooseWalletViewModel: ViewModelType {

    struct Input: InputType {
        struct FromView {
            let createNewTrigger: Driver<Void>
            let restoreTrigger: Driver<Void>
        }
        let fromView: FromView
        init(fromView: FromView, fromController: NotUsed = nil) {
            self.fromView = fromView
        }
    }

    struct Output {}

    func transform(input: Input) -> Output {

        input.fromView.createNewTrigger.do(onNext: {
            self.navigateTo(.createNewWallet)
        }).drive().disposed(by: bag)

        input.fromView.restoreTrigger.do(onNext: {
            self.navigateTo(.restoreWallet)
        }).drive().disposed(by: bag)

        return Output()
    }
}
