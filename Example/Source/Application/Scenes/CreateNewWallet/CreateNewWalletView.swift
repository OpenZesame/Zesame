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

    private lazy var createNewWalletButton: UIButton = "New Wallet"

    // MARK: - StackViewStyling
    lazy var stackViewStyle: UIStackView.Style = [createNewWalletButton, .spacer]
}

// MARK: - ViewModelled
extension CreateNewWalletView: ViewModelled {
    typealias ViewModel = CreateNewWalletViewModel
    var inputFromView: ViewModel.Input {
        return ViewModel.Input()
    }
}
