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
    private let wallet: Wallet

    init(_ navigation: @escaping NavigationTo, service: DefaultZilliqaService) {
        self.navigateTo = navigation
        self.service = service
        self.wallet = service.wallet
    }
}

extension SendViewModel: ViewModelType {

    struct Input: InputType {
        struct FromView {
            let sendTrigger: Driver<Void>
            let recepientAddress: Driver<String>
            let amountToSend: Driver<String>
            let gasLimit: Driver<String>
            let gasPrice: Driver<String>
        }
        let fromView: FromView

        init(fromView: FromView, fromController: NotUsed = nil) {
            self.fromView = fromView
        }
    }

    struct Output {
        let address: Driver<String>
        let balance: Driver<String>
        let transactionId: Driver<String>
    }

    func transform(input: Input) -> Output {

        let balanceAndNonce = service.rx.getBalance().asDriverOnErrorReturnEmpty()

        let _keyPair = service.wallet.keyPair
        let wallet: Driver<Wallet> = balanceAndNonce.map { balance in
            let amount = try! Amount(double: Double(balance.balance)!)
            return Wallet(keyPair: _keyPair, balance: amount, nonce: Nonce(balance.nonce))
        }

        let balance = wallet.map { "\($0.balance.amount) ZILs" }

        let recipient = input.fromView.recepientAddress.map { Recipient(string: $0) }.filterNil()
        let amount = input.fromView.amountToSend.map { Double($0) }.filterNil()
        let gasLimit = input.fromView.gasLimit.map { Double($0) }.filterNil()
        let gasPrice = input.fromView.gasPrice.map { Double($0) }.filterNil()

        let payment = Driver.combineLatest(recipient, amount, gasLimit, gasPrice) {
            Payment(to: $0, amount: $1, gasLimit: $2, gasPrice: $3, from: self.wallet)
        }.filterNil()

        let transactionId: Driver<String> = input.fromView.sendTrigger
            .withLatestFrom(payment)
            .flatMapLatest {
                self.service.rx.signAndMakeTransaction(payment: $0, using: self.wallet.keyPair)
                .map {
                    $0.transactionId
                }.asDriverOnErrorReturnEmpty()
        }

        return Output(
            address: wallet.map { $0.address.address },
            balance: balance,
            transactionId: transactionId
        )
    }
}
