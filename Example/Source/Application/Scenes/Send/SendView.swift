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

    private lazy var addressLabelTitle: UILabel = "Your Public Address"
    private lazy var addressLabelValue = UILabel.Style("", height: nil, numberOfLines: 0).make()
    private lazy var balanceLabelTitle: UILabel = "Balance"
    private lazy var balanceLabelValue: UILabel = "🤷‍♀️"
    private lazy var sendButton: UIButton = "Send"

    // MARK: - StackViewStyling
    lazy var stackViewStyle: UIStackView.Style = [
        addressLabelTitle,
        addressLabelValue,
        balanceLabelTitle,
        balanceLabelValue,
        sendButton,
        .spacer
    ]
}

// MARK: - SingleContentView
extension SendView: ViewModelled {
    typealias ViewModel = SendViewModel

    var inputFromView: InputFromView {
        return InputFromView(sendTrigger: sendButton.rx.tap.asDriver())
    }

    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return [
            viewModel.address --> addressLabelValue,
            viewModel.balance --> balanceLabelValue
        ]
    }
}
