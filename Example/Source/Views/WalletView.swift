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


final class WalletView: UIStackView, StackViewStyling {

    private lazy var addressLabels = LabelsView(
        titleStyle: "Your Public Address"
    )

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
        addressLabels
        ], spacing: 16, margin: 0)
}

extension WalletView {

    func populate(with wallet: Wallet) {
        setAddress(wallet.address)
    }

    func setAddress(_ address: AddressChecksummedConvertible) {
        setAddress(address.checksummedAddress.checksummed.value)
    }

    func setAddress(_ address: String) {
        addressLabels.setValue(address)
    }
}

import RxSwift
import RxCocoa
extension Reactive where Base == WalletView {
    var wallet: Binder<Wallet> {
        return Binder(base) {
            $0.populate(with: $1)
        }
    }
}

