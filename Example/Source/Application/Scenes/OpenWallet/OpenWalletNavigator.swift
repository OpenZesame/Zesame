//
//  OpenWalletNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

public protocol OpenWalletNavigator {
    func toOpenWallet()
    func toCreateNewWallet()
    func toRestoreWallet()
}

public final class DefaultOpenWalletNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

extension DefaultOpenWalletNavigator: OpenWalletNavigator {}
public extension DefaultOpenWalletNavigator {
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

    func toRestoreWallet() {}
}
