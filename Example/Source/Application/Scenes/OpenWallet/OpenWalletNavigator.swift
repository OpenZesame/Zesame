//
//  OpenWalletNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift
import ZilliqaSDK

protocol OpenWalletNavigator: AnyObject {
    func toOpenWallet()
    func toCreateNewWallet()
    func toRestoreWallet()
}

final class DefaultOpenWalletNavigator {
    private let navigationController: UINavigationController
    private let walletOpened: (Wallet) -> Void

    init(navigationController: UINavigationController, walletOpened: @escaping (Wallet) -> Void) {
        self.navigationController = navigationController
        self.walletOpened = walletOpened
    }
}

extension DefaultOpenWalletNavigator: OpenWalletNavigator {

    func toOpenWallet() {
        let viewModel = OpenWalletViewModel(navigator: self)
        let vc = OpenWalletController(viewModel: viewModel)
        vc.navigationItem.hidesBackButton = true
        navigationController.pushViewController(vc, animated: false)
    }

    func toCreateNewWallet() {
        let navigator = DefaultCreateNewWalletNavigator(navigationController: navigationController, walletOpened: walletOpened)
        let viewModel = CreateNewWalletViewModel(navigator: navigator)
        let vc = CreateNewWalletController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func toRestoreWallet() {
        let navigator = DefaultRestoreWalletNavigator(navigationController: navigationController, walletOpened: walletOpened)
        let viewModel = RestoreWalletViewModel(navigator: navigator)
        let vc = RestoreWalletController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
