//
//  AppCoordinator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import ZilliqaSDK

typealias Navigation<N: Navigator> = (N.Destination) -> Void
protocol Navigator {
    associatedtype Destination

    func navigate(to destination: Destination)
    func start()
}
extension Navigator {
    func start() { fatalError("impl me") }
}

final class AppNavigator: Navigator {
    enum Destination {
        case chooseWallet
        case chosen(wallet: Wallet)
        case main
    }

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    deinit {
        print("💣 AppNavigator")
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

private extension AppNavigator {
    func startChooseWalletFlow() {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let chooseWalletNavigator = ChooseWalletNavigator(appNavigator: self, navigationController: navigationController)

        chooseWalletNavigator.start()


    }

    func startMainFlow(wallet: Wallet) {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let mainNavigator = MainNavigator(navigationController: navigationController, wallet: wallet)
        mainNavigator.start()
    }
}

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

    deinit {
        print("💣 MainNavigator")
    }

    init(navigationController: UINavigationController, wallet: Wallet) {
        self.navigationController = navigationController
        self.wallet = wallet

        tabBarController = UITabBarController()

        // SEND
        let sendNavigationController = UINavigationController()
        sendNavigationController.tabBarItem = UITabBarItem("Send")
        sendNavigator = SendNavigator(navigationController: sendNavigationController, wallet: wallet)
        sendNavigator.start()

        // SETTINGS
        let settingsNavigationController = UINavigationController()
        settingsNavigationController.tabBarItem = UITabBarItem("Settings")
        settingsNavigator = SettingsNavigator(navigationController: settingsNavigationController)
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

final class SettingsNavigator {

    init(navigationController: UINavigationController) {
        navigationController.pushViewController(SettingsController(), animated: false)
    }
    func start() {}
}

final class SettingsController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        title = "SETTINGS"
    }
}

extension UITabBarItem {
    convenience init(_ title: String) {
        self.init(title: title, image: nil, selectedImage: nil)
    }
}
