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

    lazy var privateKeyField: UITextField = "Private Key"
    lazy var restoreWalletButton: UIButton = "Restore Wallet"

    lazy var stackViewStyle: UIStackView.Style = [privateKeyField, restoreWalletButton, .spacer]
}

extension RestoreWalletView: SingleContentView {
    typealias ViewModel = RestoreWalletViewModel
    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return []
    }
}
