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

        let sendNavigationController = UINavigationController()
        let sendNavigator = DefaultSendNavigator(navigationController: sendNavigationController)
        
        sendNavigationController.tabBarItem = UITabBarItem(title: "Send", image: nil, selectedImage: nil)
        sendNavigator.toSend()

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [sendNavigationController]

        let rootNavigationController = UINavigationController(rootViewController: tabBarController)

        window.rootViewController = rootNavigationController


//        let openWalletNavigation = UINavigationController()
        let openWalletNavigator = DefaultOpenWalletNavigator(navigationController: rootNavigationController) { [weak self] openedWallet in
            self?.goHome(in: window, wallet: openedWallet)
        }

        if !isWalletConfigured {
            openWalletNavigator.toOpenWallet()
//            rootNavigationController.present(openWalletNavigation, animated: true, completion: nil)
        }
    }
}

private extension Application {
    /// Configures TabBarController
    func goHome(in window: UIWindow, wallet: Wallet) {
        UnsafeCache.unsafeStore(value: wallet.keyPair.privateKey.asHexStringLength64(), forKey: .unsafePrivateKeyHex)
        print("Opened wallet, `\(wallet)`, configure tabs in window: `\(window)`")
    }

    var isWalletConfigured: Bool {
        return UnsafeCache.wallet != nil
    }
}


/// ⚠️ THIS IS TERRIBLE! DONT USE THIS! This is HIGHLY unsafe and secure. It is temporary and will be removed soon.
struct UnsafeCache {
    enum Key: String {
        case unsafePrivateKeyHex
    }

    static func stringForKey(_ key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }

    static var wallet: Wallet? {
        guard let privateKeyHex = UnsafeCache.privateKeyHex else { return nil }
        return Wallet(privateKeyHex: privateKeyHex)
    }

    static var privateKeyHex: String? {
        return stringForKey(.unsafePrivateKeyHex)
    }

    /// ⚠️ THIS IS TERRIBLE! DONT USE THIS!
    static func unsafeStore(value: Any, forKey key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func deleteValueFor(key: Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}

//extension UIViewController {
//    @nonobjc convenience override init() {
//        self.init(nibName: nil, bundle: nil)
//    }
//}

//extension UITabBarItem: ExpressibleByStringLiteral {
//    public convenience init(stringLiteral title: String) {
//fatalError()
//    }
//}
