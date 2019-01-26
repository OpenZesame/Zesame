// 
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
        let fetchBalanceTrigger: Driver<Void>
        let recepientAddress: Driver<String>
        let amountToSend: Driver<String>
        let gasPrice: Driver<String>
        let password: Driver<String>
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
                    .do(onNext: {
                        print("Got balance: \($0)")
                    }, onError: {
                        print("Failed to get balance, error \($0)")
                    })
                    .asDriverOnErrorReturnEmpty()
        }

        let recipient = input.recepientAddress.map { try? Address(string: $0) }

        let amount = input.amountToSend.map { try? ZilAmount(zil: $0) }

        let gasPrice = input.gasPrice.map { try? GasPrice(li: $0) }

        let payment: Driver<Payment?> = Driver.combineLatest(recipient, amount, gasPrice, balanceAndNonce) {
            guard let to = $0, let amount = $1, let price = $2, case let nonce = $3.nonce else {
                return nil
            }
            return Payment(to: to, amount: amount, gasPrice: price, nonce: nonce)
        }

        let network = service.getNetworkFromAPI().map { $0.network }

        let receipt: Driver<TransactionReceipt> = input.sendTrigger
            .withLatestFrom(Driver.combineLatest(payment.filterNil(), wallet, input.password, network.asDriverOnErrorReturnEmpty()) { (payment: $0, keystore: $1.keystore, encyptedBy: $2, network: $3) })
            .flatMapLatest {
                print("Trying to pay: \($0.payment)")
                return self.service.sendTransaction(for: $0.payment, keystore: $0.keystore, password: $0.encyptedBy, network: $0.network)
                    .do(onNext: {
                        print("Sent tx id: \($0.transactionIdentifier)")
                    }, onError: {
                        print("Failed to send transaction, error: \($0)")
                    })
                    .flatMapLatest {
                        self.service.hasNetworkReachedConsensusYetForTransactionWith(id: $0.transactionIdentifier)
                    } .asDriverOnErrorReturnEmpty()
        }

        return Output(
            isFetchingBalance: activityIndicator.asDriver(),
            isSendButtonEnabled: payment.map { $0 != nil },
            address: wallet.map { $0.address.asString },
            nonce: balanceAndNonce.map { "\($0.nonce.nonce)" },
            balance: balanceAndNonce.map { "\($0.balance.zilString)" },
            receipt: receipt.map { "Tx fee: \($0.totalGasCost) zil, for tx: \($0.transactionId)" }
        )
    }
}
