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

import UIKit
import RxSwift
import RxCocoa
import Zesame

// MARK: - SendView
final class SendView: ScrollingStackView {

    private lazy var walletBalanceView = WalletBalanceView()

    private lazy var recipientAddressField = UITextField.Style("To address", text: "zil175grxdeqchwnc0qghj8qsh5vnqwww353msqj82").make()
    private lazy var amountToSendField = UITextField.Style("ZilAmount", text: "1234").make()
    private lazy var gasExplainedLabel = UILabel.Style("Gas is measured in Li (\(Li.powerOf))").make()

    private lazy var gasPriceField = UITextField.Style("Gas price (> \(GasPrice.min.liString)", text: "\(GasPrice.min.liString)").make()
    private lazy var encryptionPassword = UITextField.Style("Wallet Encryption Password", text: "Nosnosnos").make()
    private lazy var sendButton: UIButton = "Send"
    private lazy var transactionIdentifierLabel: UILabel = "No tx"

    // MARK: - StackViewStyling
    lazy var stackViewStyle: UIStackView.Style = [
        walletBalanceView,
        recipientAddressField,
        amountToSendField,
        gasExplainedLabel,
        gasPriceField,
        encryptionPassword,
        sendButton,
        transactionIdentifierLabel,
        .spacer
    ]

    override func setup() {
        sendButton.isEnabled = false
    }
}

// MARK: - SingleContentView
extension SendView: ViewModelled {
    typealias ViewModel = SendViewModel

    var inputFromView: ViewModel.Input {
        return ViewModel.Input(
            fetchBalanceTrigger: rx.pullToRefreshTrigger,
            recepientAddress: recipientAddressField.rx.text.orEmpty.asDriver(),
            amountToSend: amountToSendField.rx.text.orEmpty.asDriver(),
            gasPrice: gasPriceField.rx.text.orEmpty.asDriver(),
            password: encryptionPassword.rx.text.orEmpty.asDriver(),
            sendTrigger: sendButton.rx.tap.asDriver()
        )
    }

    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return [
            viewModel.isFetchingBalance        --> rx.isRefreshing,
            viewModel.isSendButtonEnabled --> sendButton.rx.isEnabled,
            viewModel.address           --> walletBalanceView.rx.address,
            viewModel.balance           --> walletBalanceView.rx.balance,
            viewModel.nonce           --> walletBalanceView.rx.nonce,
            viewModel.receipt    --> transactionIdentifierLabel
        ]
    }
}
