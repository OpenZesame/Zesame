//
//  SettingsView.swift
//  ZesameiOSExample
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - SettingsView
final class SettingsView: ScrollingStackView {


    private lazy var passphraseToDecryptWalletField = UITextField.Style("Passphrase", text: "Nosnosnos").make()
    private lazy var revealPrivateKeyButton: UIButton = "Reveal private key"

    private lazy var privateKeyLabels = LabelsView(
        titleStyle: "Private key",
        valueStyle: "🤷‍♀️",
        stackViewStyle: UIStackView.Style(alignment: .center)
    )

    private lazy var appVersionLabels = LabelsView(
        titleStyle: "App Version",
        valueStyle: "🤷‍♀️",
        stackViewStyle: UIStackView.Style(alignment: .center)
    )

    private lazy var removeWalletButton: UIButton = "Remove Wallet"

    lazy var stackViewStyle: UIStackView.Style = [
        passphraseToDecryptWalletField,
        revealPrivateKeyButton,
        privateKeyLabels,
        appVersionLabels,
        .spacer,
        removeWalletButton
    ]
}

extension SettingsView: ViewModelled {
    
    typealias ViewModel = SettingsViewModel

    func populate(with viewModel: ViewModel.Output) -> [Disposable] { 
        return [
            viewModel.privateKey --> privateKeyLabels,
        	viewModel.appVersion --> appVersionLabels
        ]
    }

    var inputFromView: ViewModel.Input {
        return ViewModel.Input(
            passphrase: passphraseToDecryptWalletField.rx.text.orEmpty.asDriver(),
            revealPrivateKeyTrigger: revealPrivateKeyButton.rx.tap.asDriver(),
            removeWalletTrigger: removeWalletButton.rx.tap.asDriver()
        )
    }
}
