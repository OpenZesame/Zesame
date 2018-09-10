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
    private let service: DefaultZilliqaService

    init(_ navigation: @escaping NavigationTo, service: DefaultZilliqaService) {
        self.navigateTo = navigation
        self.service = service
    }
}

extension SendViewModel: ViewModelType {

    struct Input: InputType {
        struct FromView {
            let sendTrigger: Driver<Void>
        }
        let fromView: FromView

        init(fromView: FromView, fromController: NotUsed = nil) {
            self.fromView = fromView
        }
    }

    struct Output {
        let address: Driver<String>
        let balance: Driver<String>
    }

    func transform(input: Input) -> Output {

        let wallet = Driver.just(service.wallet)

        let balance = service.rx.getBalance().map { "\($0.balance) ZILs" }

        return Output(
            address: wallet.map { $0.address.address },
            balance: balance
        )
    }
}
