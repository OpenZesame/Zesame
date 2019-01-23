//
// Copyright 2019 Open Zesame
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under thexc License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
