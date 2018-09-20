//
//  SendView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - SendView
final class SendView: StackViewOwningView, StackViewStyling {

    private lazy var addressLabels = LabelsView(
        titleStyle: "Your Public Address",
        valueStyle: UILabel.Style(numberOfLines: 0)
    )

    private lazy var publicKeyLabels = LabelsView(
        titleStyle: "Your Public Key (compressed)",
        valueStyle: UILabel.Style(numberOfLines: 0)
    )

    private lazy var balanceLabels = LabelsView(titleStyle: "Balance", valueStyle: "🤷‍♀️")
    private lazy var nonceLabels = LabelsView(titleStyle: "Current wallet nonce", valueStyle: "🤷‍♀️")

    private lazy var recipientAddressField = UITextField.Style("To address", text: "9CA91EB535FB92FDA5094110FDAEB752EDB9B039").make()
    private lazy var amountToSendField = UITextField.Style("Amount", text: "11").make()
    private lazy var gasLimitField = UITextField.Style("Gas limit", text: "1").make()
    private lazy var gasPriceField = UITextField.Style("Gas price", text: "1").make()
    private lazy var sendButton: UIButton = "Send"
    private lazy var transactionIdentifierLabel: UILabel = "No tx"

    // MARK: - StackViewStyling
    lazy var stackViewStyle = UIStackView.Style([
        addressLabels,
        publicKeyLabels,
        balanceLabels,
        nonceLabels,
        recipientAddressField,
        amountToSendField,
        gasLimitField,
        gasPriceField,
        sendButton,
        transactionIdentifierLabel,
        .spacer
        ], spacing: 16, margin: 16)
}

// MARK: - SingleContentView
extension SendView: ViewModelled {
    typealias ViewModel = SendViewModel

    var inputFromView: ViewModel.Input {
        return ViewModel.Input(
            sendTrigger: sendButton.rx.tap.asDriver(),
            recepientAddress: recipientAddressField.rx.text.orEmpty.asDriver(),
            amountToSend: amountToSendField.rx.text.orEmpty.asDriver(),
            gasLimit: gasLimitField.rx.text.orEmpty.asDriver(),
            gasPrice: gasPriceField.rx.text.orEmpty.asDriver()
        )
    }

    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return [
            viewModel.address --> addressLabels,
            viewModel.publicKey --> publicKeyLabels,
            viewModel.balance --> balanceLabels,
            viewModel.nonce --> nonceLabels,
            viewModel.transactionId --> transactionIdentifierLabel
        ]
    }
}
