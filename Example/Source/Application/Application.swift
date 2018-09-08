//
//  Application.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import ZilliqaSDK

final class Application {
    static let shared = Application()

    private init() {}

    func configureMainInterface(in window: UIWindow) {

        let navigationController = UINavigationController()

        window.rootViewController = navigationController

        let openWalletNavigator = DefaultOpenWalletNavigator(navigationController: navigationController) { [goHome] openedWallet in
            goHome(window, openedWallet)
        }

        openWalletNavigator.toOpenWallet()
    }
}

private extension Application {
    /// Configures TabBarController
    func goHome(in window: UIWindow, wallet: Wallet) {
        print("Opened wallet, `\(wallet)`, configure tabs in window: `\(window)`")
    }
}
