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

public class ActivityIndicator: SharedSequenceConvertibleType {
    public typealias E = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _variable = Variable(false)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    public init() {
        _loading = _variable.asDriver()
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.E> {
        return source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendStopLoading()
            }, onCompleted: {
                self.sendStopLoading()
            }, onSubscribe: subscribed)
    }

    private func subscribed() {
        _lock.lock()
        _variable.value = true
        _lock.unlock()
    }

    private func sendStopLoading() {
        _lock.lock()
        _variable.value = false
        _lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, E> {
        return _loading
    }
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<E> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}

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
        let fetchBalanceTrigger: Driver<Void>
        let recepientAddress: Driver<String>
        let amountToSend: Driver<String>
        let gasPrice: Driver<String>
        let passphrase: Driver<String>
        let sendTrigger: Driver<Void>
    }

    struct Output {
        let isFetchingBalance: Driver<Bool>
        let isSendButtonEnabled: Driver<Bool>
        let address: Driver<String>
        let nonce: Driver<String>
        let balance: Driver<String>
        let receipt: Driver<String>
    }

    func transform(input: Input) -> Output {

        let fetchBalanceSubject = BehaviorSubject<Void>(value: ())

        let fetchTrigger = Driver.merge(fetchBalanceSubject.asDriverOnErrorReturnEmpty(), input.fetchBalanceTrigger)

        let activityIndicator = ActivityIndicator()

        let balanceAndNonce: Driver<BalanceResponse> = fetchTrigger.withLatestFrom(wallet) { _, w in w.address }
            .flatMapLatest {
                self.service
                    .getBalance(for: $0)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorReturnEmpty()
        }

        let recipient = input.recepientAddress.map { Address(uncheckedString: $0) }

        let amount = input.amountToSend.map { try? ZilAmount(string: $0) }

        let gasPrice = input.gasPrice.map { try? GasPrice(li: $0) }

        let payment: Driver<Payment?> = Driver.combineLatest(recipient, amount, gasPrice, balanceAndNonce) {
            guard let to = $0, let amount = $1, let price = $2, case let nonce = $3.nonce else {
                return nil
            }
            return Payment(to: to, amount: amount, gasPrice: price, nonce: nonce)
        }

        let receipt: Driver<TransactionReceipt> = input.sendTrigger
            .withLatestFrom(Driver.combineLatest(payment.filterNil(), wallet, input.passphrase) { (payment: $0, keystore: $1.keystore, encyptedBy: $2) })
            .flatMapLatest {
                self.service.sendTransaction(for: $0.payment, keystore: $0.keystore, passphrase: $0.encyptedBy)
                    .flatMapLatest {
                        self.service.hasNetworkReachedConsensusYetForTransactionWith(id: $0.transactionIdentifier)
                    } .asDriverOnErrorReturnEmpty()
        }

        return Output(
            isFetchingBalance: activityIndicator.asDriver(),
            isSendButtonEnabled: payment.map { $0 != nil },
            address: wallet.map { $0.address.checksummedHex },
            nonce: balanceAndNonce.map { "\($0.nonce.nonce)" },
            balance: balanceAndNonce.map { "\(Int($0.balance.amount.inZil.significand)) Zil" },
            receipt: receipt.map { "Tx fee: \($0.totalGasCost) zil, for tx: \($0.transactionId)" }
        )
    }
}
