// 
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - SettingsView
final class SettingsView: ScrollingStackView {


    private lazy var passwordToDecryptWalletField = UITextField.Style("Password", text: "Nosnosnos").make()
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
        passwordToDecryptWalletField,
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
            password: passwordToDecryptWalletField.rx.text.orEmpty.asDriver(),
            revealPrivateKeyTrigger: revealPrivateKeyButton.rx.tap.asDriver(),
            removeWalletTrigger: removeWalletButton.rx.tap.asDriver()
        )
    }
}
