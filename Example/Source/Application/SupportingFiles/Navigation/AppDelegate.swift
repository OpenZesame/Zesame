//
//  AppDelegate.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-05-26.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import ZilliqaSDK

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?

    private lazy var appNavigator: AppNavigator = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.makeKeyAndVisible()
        return AppNavigator(window: window)
    }()
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appNavigator.start()
        return true
    }
}
