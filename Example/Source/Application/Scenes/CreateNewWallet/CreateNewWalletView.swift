//
//  CreateNewWalletView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift

public final class CreateNewWalletView: StackViewOwningView {
    lazy var createNewWalletButton: UIButton = .make("New Wallet")
    override func makeStackView() -> UIStackView { return .make([createNewWalletButton, .spacer]) }
}

// MARK: - SingleContentView
extension CreateNewWalletView: SingleContentView {}
public extension CreateNewWalletView {
    typealias ViewModel = CreateNewWalletViewModel
    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return []
    }
}
