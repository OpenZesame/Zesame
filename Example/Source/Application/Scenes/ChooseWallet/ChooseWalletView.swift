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

    lazy var createNewWalletButton: UIButton = "New Wallet"
    lazy var restoreWalletButton: UIButton = "Restore Wallet"

    lazy var stackViewStyle: UIStackView.Style = [createNewWalletButton, restoreWalletButton, .spacer]
}

extension ChooseWalletView: ViewModelled {
    typealias ViewModel = ChooseWalletViewModel
    var inputFromView: InputFromView {
        return InputFromView(
            createNewTrigger: createNewWalletButton.rx.tap.asDriver(),
            restoreTrigger: restoreWalletButton.rx.tap.asDriver()
        )
    }
}
