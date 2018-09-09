//
//  MainNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import ZilliqaSDK


final class MainNavigator: Navigator {
    enum Destination {
        case tab(Tab)
        enum Tab: Int {
            case send, settings
        }

        static var send: Destination { return .tab(.send) }
        static var settings: Destination { return .tab(.settings) }
    }

    private weak var navigationController: UINavigationController?
    private let tabBarController: UITabBarController
    private let sendNavigator: SendNavigator
    private let settingsNavigator: SettingsNavigator
    private let wallet: Wallet
    private let chooseWallet: () -> Void

    deinit {
        print("💣 MainNavigator")
    }

    init(navigationController: UINavigationController, wallet: Wallet, chooseWallet: @escaping () -> Void) {
        self.navigationController = navigationController
        self.wallet = wallet
        self.chooseWallet = chooseWallet

        tabBarController = UITabBarController()

        // SEND
        let sendNavigationController = UINavigationController()
        sendNavigationController.tabBarItem = UITabBarItem("Send")
        sendNavigator = SendNavigator(navigationController: sendNavigationController, wallet: wallet)
        sendNavigator.start()

        // SETTINGS
        let settingsNavigationController = UINavigationController()
        settingsNavigationController.tabBarItem = UITabBarItem("Settings")
        settingsNavigator = SettingsNavigator(navigationController: settingsNavigationController, chooseWallet: chooseWallet)
        settingsNavigator.start()


        tabBarController.viewControllers = [
            sendNavigationController,
            settingsNavigationController
        ]

        navigationController.pushViewController(tabBarController, animated: false)
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .tab(let tab): focus(tab: tab)
        }
    }

    func start() {
        navigate(to: .send)
    }
}

private extension MainNavigator {
    func focus(tab: Destination.Tab) {
        tabBarController.selectedIndex = tab.rawValue
    }
}
