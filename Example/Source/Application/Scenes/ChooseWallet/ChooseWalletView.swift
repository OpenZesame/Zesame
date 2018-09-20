//
//  ChooseWalletView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift

final class ChooseWalletView: StackViewOwningView, StackViewStyling {

    private lazy var createNewWalletButton: UIButton = "New Wallet"
    private lazy var restoreWalletButton: UIButton = "Restore Wallet"

    lazy var stackViewStyle = UIStackView.Style([
        .spacer,
        createNewWalletButton,
        restoreWalletButton,
        .spacer
        ], spacing: 16, margin: 16)
}

extension ChooseWalletView: ViewModelled {
    typealias ViewModel = ChooseWalletViewModel
    var inputFromView: ViewModel.Input {
        return ViewModel.Input(
            createNewTrigger: createNewWalletButton.rx.tap.asDriver(),
            restoreTrigger: restoreWalletButton.rx.tap.asDriver()
        )
    }
}
