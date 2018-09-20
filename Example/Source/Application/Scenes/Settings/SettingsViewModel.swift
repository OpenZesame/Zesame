//
//  SettingsViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SettingsViewModel {
    private let bag = DisposeBag()
    
    typealias NavigationTo = Navigation<SettingsNavigator>
    private let navigateTo: NavigationTo

    init(_ navigation: @escaping NavigationTo) {
        self.navigateTo = navigation
    }
}

extension SettingsViewModel: ViewModelType {

    struct Input {
        let removeWalletTrigger: Driver<Void>
    }

    struct Output {
        let appVersion: Driver<String>
    }

    func transform(input: Input) -> Output {

        input.removeWalletTrigger
            .do(onNext: {
                self.navigateTo(.chooseWallet)
            }).drive().disposed(by: bag)

        return Output(
            appVersion: .just("HC: 0.0.1")
        )
    }
}
