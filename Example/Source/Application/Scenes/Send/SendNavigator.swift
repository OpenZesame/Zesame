//
//  SendNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ZilliqaSDK

// MARK: - SendNavigator
final class SendNavigator: Navigator {
    enum Destination {
        case send
    }

    private weak var navigationController: UINavigationController?

    private let wallet: Wallet

    deinit {
        print("💣 SendNavigator")
    }

    init(navigationController: UINavigationController, wallet: Wallet) {
        self.navigationController = navigationController
        self.wallet = wallet
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .send:
            navigationController?.pushViewController(
                SendController(
                    viewModel: SendViewModel(navigate(to:), wallet: wallet)
                ),
                animated: true
            )
        }
    }

    func start() {
        navigate(to: .send)
    }
}
