//
//  OpenWalletView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift

public final class OpenWalletView: StackViewOwningView {

    lazy var createNewWalletButton: UIButton = .make("New Wallet")
    lazy var restoreWalletButton: UIButton = .make("Restore Wallet")
    override func makeStackView() -> UIStackView { return .make([createNewWalletButton, restoreWalletButton, .spacer]) }
}

extension OpenWalletView: SingleContentView {}
public extension OpenWalletView {
    typealias ViewModel = OpenWalletViewModel
    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return [
            viewModel.createNew.drive(),
            viewModel.restore.drive()
        ]
    }
}
