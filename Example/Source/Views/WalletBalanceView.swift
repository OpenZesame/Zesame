//
//  WalletBalanceView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-10-07.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import Zesame

final class WalletBalanceView: UIStackView, StackViewStyling {
    private lazy var walletView = WalletView()
    private lazy var balanceView = BalanceView()

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

extension WalletBalanceView {

    func populate(with walletBalance: WalletBalance) {
        walletView.populate(with: walletBalance.wallet)
        balanceView.populate(with: walletBalance)
    }
}


import RxSwift
import RxCocoa
extension Reactive where Base == WalletBalanceView {
    var wallet: Binder<WalletBalance> {
        return Binder(base) {
            $0.populate(with: $1)
        }
    }
}
