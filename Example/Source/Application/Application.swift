//
//  Application.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

final class Application {
    static let shared = Application()

    private init() {}

    func configureMainInterface(in window: UIWindow) {

        let navigationController = UINavigationController()

        window.rootViewController = navigationController

        let openWalletNavigator = DefaultOpenWalletNavigator(navigationController: navigationController)
        openWalletNavigator.toOpenWallet()
    }
}
