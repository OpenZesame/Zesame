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

final class RestoreWalletView: ScrollingStackView {

    private lazy var privateKeyField: UITextField = "Private Key"
    private lazy var encryptionPasswordField = UITextField.Style("Encryption password", text: "Nosnosnos").make()
    private lazy var confirmEncryptionPasswordField = UITextField.Style("Confirm encryption password", text: "Nosnosnos").make()
    private lazy var restoreWalletButton = UIButton.Style("Restore Wallet", isEnabled: false).make()

    lazy var stackViewStyle: UIStackView.Style = [
        privateKeyField,
        encryptionPasswordField,
        confirmEncryptionPasswordField,
        restoreWalletButton,
        .spacer
    ]
}

extension RestoreWalletView: ViewModelled {
    typealias ViewModel = RestoreWalletViewModel
    var inputFromView: ViewModel.Input {
        return ViewModel.Input(
            privateKey: privateKeyField.rx.text.asDriver(),
            encryptionPassword: encryptionPasswordField.rx.text.asDriver(),
            confirmEncryptionPassword: confirmEncryptionPasswordField.rx.text.asDriver(),
            restoreTrigger: restoreWalletButton.rx.tap.asDriver()
        )
    }

    func populate(with viewModel: RestoreWalletViewModel.Output) -> [Disposable] {
        return [
            viewModel.isRestoreButtonEnabled --> restoreWalletButton.rx.isEnabled
        ]
    }
}
