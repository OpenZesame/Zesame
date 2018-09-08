//
//  CreateNewWalletViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

struct CreateNewWalletViewModel {
    private let navigator: CreateNewWalletNavigator
    init(navigator: CreateNewWalletNavigator) {
        self.navigator = navigator
    }
}

extension CreateNewWalletViewModel: ViewModelled {}
extension CreateNewWalletViewModel {
    struct Input {}
    struct Output {}
    func transform(input: Input) -> Output {
        return Output()
    }
}
