//
//  AppCoordinator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import ZilliqaSDK

final class AppNavigator {

    private let window: UIWindow
    private var currentNavigator: AnyNavigator?

    init(window: UIWindow) {
        self.window = window
    }
}

// MARK: - Conformance: Navigator
extension AppNavigator: Navigator {

    enum Destination {
        case chooseWallet
        case chosen(wallet: Wallet)
        case main
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .chooseWallet: startChooseWalletFlow()
        case .chosen(let chosenWallet):
            Unsafe︕！Cache.unsafe︕！Store(wallet: chosenWallet)
            startMainFlow(wallet: chosenWallet)
        case .main:
            startMainFlow(wallet: Unsafe︕！Cache.wallet!)
        }
    }

    func start() {
        if Unsafe︕！Cache.isWalletConfigured {
            navigate(to: .main)
        } else {
            navigate(to: .chooseWallet)
        }
    }
}

// MARK: - Private
private extension AppNavigator {
    func startChooseWalletFlow() {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let chooseWalletNavigator = ChooseWalletNavigator(navigationController: navigationController) { [weak self] in
            self?.navigate(to: .chosen(wallet: $0))
        }

        currentNavigator = chooseWalletNavigator
        chooseWalletNavigator.start()
    }

    func startMainFlow(wallet: Wallet) {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let mainNavigator = MainNavigator(navigationController: navigationController, wallet: wallet, chooseWallet: startChooseWalletFlow)

        currentNavigator = mainNavigator
        mainNavigator.start()

    }
}
