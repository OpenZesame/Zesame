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

    lazy var addressLabelTitle: UILabel = "Your Public Address"
    lazy var addressLabelValue = UILabel.Style("", height: nil, numberOfLines: 0).make()
    lazy var balanceLabelTitle: UILabel = "Balance"
    lazy var balanceLabelValue: UILabel = "🤷‍♀️"
    lazy var sendButton: UIButton = "Send"


    lazy var stackViewStyle: UIStackView.Style = [
        addressLabelTitle,
        addressLabelValue,
        balanceLabelTitle,
        balanceLabelValue,
        sendButton,
        .spacer
    ]
}

extension SendView: SingleContentView {
    typealias ViewModel = SendViewModel
    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return [
            viewModel.address --> addressLabelValue,
            viewModel.balance --> balanceLabelValue
        ]
    }
}

infix operator -->
func --> <E>(driver: Driver<E>, binder: Binder<E>) -> Disposable {
    return driver.drive(binder)
}
func --> <E>(driver: Driver<E>, binder: Binder<E?>) -> Disposable {
    return driver.drive(binder)
}
func --> (driver: Driver<String>, label: UILabel) -> Disposable {
    return driver --> label.rx.text
}
