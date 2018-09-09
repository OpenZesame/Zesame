//
//  RestoreWalletNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import ZilliqaSDK

protocol RestoreWalletNavigator: AnyObject {
    func toOpenWallet()
    func toHome(_ wallet: Wallet)
}

final class DefaultRestoreWalletNavigator {
    private let navigationController: UINavigationController
    private let walletOpened: (Wallet) -> Void

    init(navigationController: UINavigationController, walletOpened: @escaping (Wallet) -> Void) {
        self.navigationController = navigationController
        self.walletOpened = walletOpened
    }
}

// MARK: - CreateNewWalletNavigator
extension DefaultRestoreWalletNavigator: RestoreWalletNavigator {
    func toOpenWallet() {
        navigationController.dismiss(animated: true)
    }

    func toHome(_ wallet: Wallet) {
        walletOpened(wallet)
        navigationController.popToRootViewController(animated: false)
    }
}

