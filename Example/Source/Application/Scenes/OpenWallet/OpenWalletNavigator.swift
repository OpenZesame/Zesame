//
//  OpenWalletNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

protocol OpenWalletNavigator {
    func toOpenWallet()
    func toCreateNewWallet()
    func toRestoreWallet()
}

final class DefaultOpenWalletNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

extension DefaultOpenWalletNavigator: OpenWalletNavigator {

    func toOpenWallet() {
        let viewModel = OpenWalletViewModel(navigator: self)
        let vc = OpenWalletController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func toCreateNewWallet() {
        let navigator = DefaultCreateNewWalletNavigator(navigationController: navigationController)
        let viewModel = CreateNewWalletViewModel(navigator: navigator)
        let vc = CreateNewWalletController(viewModel: viewModel)
        let nc = UINavigationController(rootViewController: vc)
        navigationController.present(nc, animated: true, completion: nil)
    }

    func toRestoreWallet() {
        let navigator = DefaultRestoreWalletNavigator(navigationController: navigationController)
        let viewModel = RestoreWalletViewModel(navigator: navigator)
        let vc = RestoreWalletController(viewModel: viewModel)
        let nc = UINavigationController(rootViewController: vc)
        navigationController.present(nc, animated: true, completion: nil)
    }
}
