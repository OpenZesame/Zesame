//
//  CreateNewWalletViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct CreateNewWalletViewModel {
    private let navigator: CreateNewWalletNavigator
    public init(navigator: CreateNewWalletNavigator) {
        self.navigator = navigator
    }
}

extension CreateNewWalletViewModel: ViewModelled {}
public extension CreateNewWalletViewModel {
    struct Input {}
    struct Output {}
    public func transform(input: Input) -> Output {
        return Output()
    }
}
