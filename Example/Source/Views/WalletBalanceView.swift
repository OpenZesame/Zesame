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
import Zesame

final class WalletBalanceView: UIStackView, StackViewStyling {
    fileprivate lazy var walletView = WalletView()
    fileprivate lazy var balanceView = BalanceView()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        apply(style: stackViewStyle)
    }

    required init(coder aDecoder: NSCoder) {
        interfaceBuilderSucks
    }

    // MARK: - StackViewStyling
    lazy var stackViewStyle = UIStackView.Style([
        walletView,
        balanceView
        ], spacing: 16, margin: 0)

}

import RxSwift
import RxCocoa
extension Reactive where Base == WalletBalanceView {

    var address: Binder<String> {
        return Binder(base) {
            $0.walletView.setAddress($1)
        }
    }

    var balance: Binder<String> {
        return Binder(base) {
            $0.balanceView.setBalance($1)
        }
    }

    var nonce: Binder<String> {
        return Binder(base) {
            $0.balanceView.setNonce($1)
        }
    }
}
