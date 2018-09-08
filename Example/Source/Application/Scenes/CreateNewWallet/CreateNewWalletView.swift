//
//  CreateNewWalletView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift

final class CreateNewWalletView: StackViewOwningView, StackViewStyling {

    lazy var createNewWalletButton: UIButton = "New Wallet"

    lazy var stackViewStyle: UIStackView.Style = [createNewWalletButton, .spacer]
}

// MARK: - SingleContentView
extension CreateNewWalletView: SingleContentView {}
extension CreateNewWalletView {
    typealias ViewModel = CreateNewWalletViewModel
}
