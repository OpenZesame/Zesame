//
// Copyright 2019 Open Zesame
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under thexc License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
