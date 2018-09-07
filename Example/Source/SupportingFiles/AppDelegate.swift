//
//  AppDelegate.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-05-26.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        Application.shared.configureMainInterface(in: window)
        self.window = window.keyedAndVisible()
        return true
    }
}


final class Application {
    static let shared = Application()

    private init() {}

    func configureMainInterface(in window: UIWindow) {
        let navigationController = UINavigationController()
        let openWalletNavigator = DefaultOpenWalletNavigator(navigationController: navigationController)
        window.rootViewController = navigationController

        openWalletNavigator.toOpenWallet()
    }
}

extension UIWindow {
    func keyedAndVisible() -> UIWindow {
        makeKeyAndVisible()
        return self
    }
}
