//
//  OpenWalletView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift

final class OpenWalletView: StackViewOwningView, StackViewStyling {

    lazy var createNewWalletButton: UIButton = "New Wallet"
    lazy var restoreWalletButton: UIButton = "Restore Wallet"

    lazy var stackViewStyle: UIStackView.Style = [createNewWalletButton, restoreWalletButton, .spacer]
}

extension OpenWalletView: SingleContentView {
    typealias ViewModel = OpenWalletViewModel
    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return [
            viewModel.createNew.drive(),
            viewModel.restore.drive()
        ]
    }
}
