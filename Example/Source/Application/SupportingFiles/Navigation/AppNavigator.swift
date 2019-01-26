// 
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import Zesame

final class AppCoordinator {

    private let window: UIWindow
    var childCoordinators = [AnyCoordinator]()

    init(window: UIWindow) {
        self.window = window
    }
}

extension AppCoordinator: Coordinator {
    func start() {
        if Unsafe︕！Cache.isWalletConfigured {
            toMain(wallet: Unsafe︕！Cache.wallet!)
        } else {
           toChooseWallet()
        }
    }
}

protocol AppNavigation: AnyObject {
    func toChooseWallet()
    func toMain(wallet: Wallet)
}

// MARK: - Private
extension AppCoordinator: AppNavigation {
    func toChooseWallet() {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let chooseWalletCoordinator = ChooseWalletCoordinator(navigationController: navigationController, navigation: self)
        childCoordinators = [chooseWalletCoordinator]
        chooseWalletCoordinator.start()
    }

    func toMain(wallet: Wallet) {
        Unsafe︕！Cache.unsafe︕！Store(wallet: wallet)
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let mainCoordinator = MainCoordinator(navigationController: navigationController, wallet: .just(wallet), navigation: self)
        childCoordinators = [mainCoordinator]
        mainCoordinator.start()
    }
}
