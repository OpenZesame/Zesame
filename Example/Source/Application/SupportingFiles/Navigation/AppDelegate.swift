//
//  AppDelegate.swift
//  ZesameiOSExample
//
//  Created by Alexander Cyon on 2018-05-26.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import Zesame

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
    fileprivate let zilliqaService = DefaultZilliqaService(network: .testnet(.prod))
    private lazy var appCoordinator: AppCoordinator = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.makeKeyAndVisible()
        return AppCoordinator(window: window)
    }()
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appCoordinator.start()
        return true
    }
}

extension AppDelegate {

    static var shared: AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("incorrect impl")
        }
        return appDelegate
    }

    static var zilliqaSerivce: DefaultZilliqaService {
        return shared.zilliqaService
    }
}
