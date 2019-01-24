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

final class CreateNewWalletView: ScrollingStackView {

//    private lazy var walletView = WalletView()
    private lazy var encryptionPasswordField: UITextField = "Encryption password"
    private lazy var confirmEncryptionPasswordField: UITextField = "Confirm encryption password"
    private lazy var createNewWalletButton = UIButton.Style("Create New Wallet", isEnabled: false).make()

    // MARK: - StackViewStyling
    lazy var stackViewStyle: UIStackView.Style = [
//        walletView,
        encryptionPasswordField,
        confirmEncryptionPasswordField,
        createNewWalletButton,
        .spacer
    ]
}

// MARK: - ViewModelled
extension CreateNewWalletView: ViewModelled {
    typealias ViewModel = CreateNewWalletViewModel
    var inputFromView: ViewModel.Input {
        return ViewModel.Input(
            encryptionPassword: encryptionPasswordField.rx.text.asDriver(),
            confirmedEncryptionPassword: confirmEncryptionPasswordField.rx.text.asDriver(),
            createWalletTrigger: createNewWalletButton.rx.tap.asDriver()
        )
    }

    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return [
            viewModel.isCreateWalletButtonEnabled --> createNewWalletButton.rx.isEnabled
//            viewModel.wallet        --> walletView.rx.wallet
        ]
    }
}
