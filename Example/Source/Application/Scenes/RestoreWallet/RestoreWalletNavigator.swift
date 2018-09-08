//
//  RestoreWalletNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

protocol RestoreWalletNavigator {
    func toOpenWallet()
    func toHome()
}

final class DefaultRestoreWalletNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

// MARK: - CreateNewWalletNavigator
extension DefaultRestoreWalletNavigator: RestoreWalletNavigator {
    func toOpenWallet() {
        navigationController.dismiss(animated: true)
    }

    func toHome() {}
}

