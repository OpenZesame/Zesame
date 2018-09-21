//
//  WalletView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-22.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import ZilliqaSDK

final class WalletView: UIStackView, StackViewStyling {

    private lazy var addressLabels = LabelsView(
        titleStyle: "Your Public Address",
        valueStyle: UILabel.Style(numberOfLines: 0)
    )

    private lazy var publicKeyLabels = LabelsView(
        titleStyle: "Your Public Key (compressed)",
        valueStyle: UILabel.Style(numberOfLines: 0)
    )

    private lazy var balanceLabels = LabelsView(titleStyle: "Balance", valueStyle: "🤷‍♀️")
    private lazy var nonceLabels = LabelsView(titleStyle: "Current wallet nonce", valueStyle: "🤷‍♀️")

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        apply(style: stackViewStyle)
        isHidden = true
        height(0)
    }

    required init(coder aDecoder: NSCoder) {
        interfaceBuilderSucks
    }

    // MARK: - StackViewStyling
    lazy var stackViewStyle = UIStackView.Style([
        addressLabels,
        publicKeyLabels,
        balanceLabels,
        nonceLabels,
        ], spacing: 16, margin: 0)
}

extension WalletView {

    func populate(with wallet: Wallet) {
        addressLabels.setValue(wallet.address.address)
        publicKeyLabels.setValue(wallet.keyPair.publicKey)
        balanceLabels.setValue(wallet.balance)
        nonceLabels.setValue(wallet.nonce.nonce)

        animate {
            $0.removeHeightAnchorConstraintIfAny()
            $0.isHidden = false
        }
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }

    func animate(duration: TimeInterval = 0.2, change: @escaping (UIView) -> Void) {
        layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            change(self)
            self.layoutIfNeeded()
            self.needsUpdateConstraints()
        }
    }

    func removeHeightAnchorConstraintIfAny() {
        constraints.first(where: { $0.firstAnchor == heightAnchor })?.isActive = false
        needsUpdateConstraints()
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

