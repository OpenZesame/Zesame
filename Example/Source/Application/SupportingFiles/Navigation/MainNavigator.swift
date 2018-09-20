//
//  MainNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import ZilliqaSDK

struct MainNavigator {

    private weak var navigationController: UINavigationController?
    private let tabBarController = UITabBarController()
    private let sendNavigator: SendNavigator
    private let settingsNavigator: SettingsNavigator
    private let wallet: Wallet
    private let chooseWallet: () -> Void

    init(navigationController: UINavigationController, wallet: Wallet, chooseWallet: @escaping () -> Void) {
        self.navigationController = navigationController
        self.wallet = wallet
        self.chooseWallet = chooseWallet

        // SEND
        let sendNavigationController = UINavigationController()
        sendNavigationController.tabBarItem = UITabBarItem("Send")
        sendNavigator = SendNavigator(navigationController: sendNavigationController, wallet: wallet)


        // SETTINGS
        let settingsNavigationController = UINavigationController()
        settingsNavigationController.tabBarItem = UITabBarItem("Settings")
        settingsNavigator = SettingsNavigator(navigationController: settingsNavigationController, chooseWallet: chooseWallet)

        tabBarController.viewControllers = [
            sendNavigationController,
            settingsNavigationController
        ]

        navigationController.pushViewController(tabBarController, animated: false)
    }
}

// MARK: - Conformance: Navigator
extension MainNavigator: Navigator {
    enum Destination {
        case tab(Tab)
        enum Tab: Int {
            case send, settings
        }
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .tab(let tab): focus(tab: tab)
        }
    }

    func start() {
        sendNavigator.start()
        settingsNavigator.start()
        navigate(to: .send)
    }
}

// MARK: Private
private extension MainNavigator {
    func focus(tab: Destination.Tab) {
        tabBarController.selectedIndex = tab.rawValue
    }
}

private extension MainNavigator.Destination {
    static var send: MainNavigator.Destination { return .tab(.send) }
    static var settings: MainNavigator.Destination { return .tab(.settings) }
}
