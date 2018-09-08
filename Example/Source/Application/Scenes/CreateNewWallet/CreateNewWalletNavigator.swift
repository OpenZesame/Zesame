//
//  CreateNewWalletNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

protocol CreateNewWalletNavigator {
    func toOpenWallet()
}

final class DefaultCreateNewWalletNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

// MARK: - CreateNewWalletNavigator
extension DefaultCreateNewWalletNavigator: CreateNewWalletNavigator {}
extension DefaultCreateNewWalletNavigator {
    func toOpenWallet() {
        navigationController.dismiss(animated: true)
    }
}
