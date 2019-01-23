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
import RxSwift
import RxCocoa
import Zesame

protocol SettingsNavigator: AnyObject {
    func toSettings()
    func toChooseWallet()
}

final class SettingsCoordinator: AnyCoordinator {

    private weak var navigationController: UINavigationController?

    private weak var navigation: AppNavigation?
    private let wallet: Observable<Wallet>

    init(navigationController: UINavigationController?, navigation: AppNavigation, wallet: Observable<Wallet>) {
        self.navigationController = navigationController
        self.navigation = navigation
        self.wallet = wallet
    }
}

// MARK: - Navigator
extension SettingsCoordinator: SettingsNavigator {

    func toChooseWallet() {
        Unsafe︕！Cache.deleteWallet()
        navigation?.toChooseWallet()
    }

    func start() {
        toSettings()
    }

    func toSettings() {
        navigationController?.pushViewController(
            Settings(
                viewModel: SettingsViewModel(navigation: self, wallet: wallet, service: AppDelegate.zilliqaSerivce.rx)
            ),
            animated: true
        )
    }
}
