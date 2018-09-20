//
//  RestoreWalletNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import ZilliqaSDK

struct RestoreWalletNavigator {

    private weak var navigationController: UINavigationController?
    private let didChooseWallet: (Wallet) -> Void

    init(navigationController: UINavigationController?, didChooseWallet: @escaping (Wallet) -> Void) {
        self.navigationController = navigationController
        self.didChooseWallet = didChooseWallet
    }
}

// MARK: - Navigator
extension RestoreWalletNavigator: Navigator {
    enum Destination {
        case restore
        case restored(Wallet)
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .restored(let wallet): didChooseWallet(wallet)
        case .restore:
            let viewModel = RestoreWalletViewModel(navigate(to:))
            let vc = RestoreWalletController(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func start() {
        navigate(to: .restore)
    }
}
