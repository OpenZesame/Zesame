//
//  SendViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ZilliqaSDK

struct SendViewModel {
    private let bag = DisposeBag()
    
    typealias NavigationTo = Navigation<SendNavigator>
    private let navigateTo: NavigationTo
    private let wallet: Wallet

    init(_ navigation: @escaping NavigationTo, wallet: Wallet) {
        self.navigateTo = navigation
        self.wallet = wallet
    }
}

extension SendViewModel: ViewModelled {
    struct Input {
        let sendTrigger: Driver<Void>
    }
    struct Output {
        let address: Driver<String>
        let balance: Driver<String>
    }
    func transform(input: Input) -> Output {

        let wallet = Driver.just(self.wallet)

        return Output(
            address: wallet.map { $0.address.address },
            balance: wallet.map { String(describing: $0.balance.amount) }
        )
    }
}
