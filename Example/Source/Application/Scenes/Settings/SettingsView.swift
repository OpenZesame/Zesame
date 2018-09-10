//
//  SettingsView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - SettingsView
final class SettingsView: StackViewOwningView, StackViewStyling {

    lazy var removeWalletButton: UIButton = "Remove Wallet"
    lazy var appVersionTitleLabel: UILabel = "App Version"
    lazy var appVersionValueLabel = UILabel.Style().make()

    lazy var stackViewStyle: UIStackView.Style = [
        removeWalletButton,
        .spacer,
        appVersionTitleLabel,
        appVersionValueLabel
    ]
}

extension SettingsView: ViewModelled {
    
    typealias ViewModel = SettingsViewModel

    func populate(with viewModel: ViewModel.Output) -> [Disposable] { 
        return [
        	viewModel.appVersion --> appVersionValueLabel
        ] 
    }

    var inputFromView: InputFromView {
        return InputFromView(
            removeWalletTrigger: removeWalletButton.rx.tap.asDriver()
        )
    }
}
