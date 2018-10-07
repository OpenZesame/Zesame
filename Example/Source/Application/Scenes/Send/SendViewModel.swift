//
//  SendViewModel.swift
//  ZesameiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Zesame

final class SendViewModel {
    private let bag = DisposeBag()
    
    private weak var navigator: SendNavigator?
    private let service: ZilliqaServiceReactive
    private let wallet: Driver<Wallet>

    init(navigator: SendNavigator, wallet: Observable<Wallet>, service: ZilliqaServiceReactive) {
        self.navigator = navigator
        self.service = service
        self.wallet = wallet.asDriverOnErrorReturnEmpty()
    }
}

extension SendViewModel: ViewModelType {

    struct Input {
        let sendTrigger: Driver<Void>
        let recepientAddress: Driver<String>
        let amountToSend: Driver<String>
        let gasLimit: Driver<String>
        let gasPrice: Driver<String>
    }

    struct Output {
        let walletBalance: Driver<WalletBalance>
        let transactionId: Driver<String>
    }

    func transform(input: Input) -> Output {

        let fetchBalanceSubject = BehaviorSubject<Void>(value: ())

        let fetchTrigger = fetchBalanceSubject.asDriverOnErrorReturnEmpty()

        let balanceAndNonce: Driver<BalanceResponse> = fetchTrigger.withLatestFrom(wallet) { _, w in w.address }
            .flatMapLatest {
            self.service
                .getBalance(for: $0)
                .asDriverOnErrorReturnEmpty()
        }

        let walletBalance = Driver.combineLatest(wallet, balanceAndNonce) { WalletBalance(wallet: $0, balanceResponse: $1) }

        let recipient = input.recepientAddress.map { Address(uncheckedString: $0) }.filterNil()
        let amount = input.amountToSend.map { Double($0) }.filterNil()
        let gasLimit = input.gasLimit.map { Double($0) }.filterNil()
        let gasPrice = input.gasPrice.map { Double($0) }.filterNil()

        let payment = Driver.combineLatest(recipient, amount, gasLimit, gasPrice, walletBalance) {
            Payment(to: $0, amount: $1, gasLimit: $2, gasPrice: $3, nonce: $4.nonce)
        }.filterNil()

        let transactionId: Driver<String> = input.sendTrigger
            .withLatestFrom(Driver.combineLatest(payment, wallet) { (payment: $0, keyPair: $1.keyPair) })
            .flatMapLatest {
                self.service.sendTransaction(for: $0.payment, signWith: $0.keyPair)
                    .asDriverOnErrorReturnEmpty()
                    // Trigger fetching of balance after successfull send
                    .do(onNext: { _ in
                        fetchBalanceSubject.onNext(())
                    })
        }

        return Output(
            walletBalance: walletBalance,
            transactionId: transactionId
        )
    }
}
