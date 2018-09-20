//
//  RestoreWalletView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift

final class RestoreWalletView: StackViewOwningView, StackViewStyling {

    private lazy var privateKeyField: UITextField = "Private Key"
    private lazy var restoreWalletButton: UIButton = "Restore Wallet"

    lazy var stackViewStyle = UIStackView.Style([
        .spacer,
        privateKeyField,
        restoreWalletButton,
        .spacer
    ], spacing: 16, margin: 16)
}

extension RestoreWalletView: ViewModelled {
    typealias ViewModel = RestoreWalletViewModel
    var inputFromView: ViewModel.Input {
        return ViewModel.Input(
            privateKey: privateKeyField.rx.text.orEmpty.asDriver(),
            restoreTrigger: restoreWalletButton.rx.tap.asDriver()
        )
    }
}
