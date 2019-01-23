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
import Zesame

final class ChooseWalletCoordinator: Coordinator {

    private weak var navigationController: UINavigationController?
    private weak var navigation: AppNavigation?

    var childCoordinators = [AnyCoordinator]()

    init(navigationController: UINavigationController, navigation: AppNavigation) {
        self.navigationController = navigationController
        self.navigation = navigation
    }
}

extension ChooseWalletCoordinator {

    func start() {
        toChooseWallet()
    }
}

protocol ChooseWalletNavigator: AnyObject {
    func toMain(wallet: Wallet)
    func toChooseWallet()
    func toCreateNewWallet()
    func toRestoreWallet()
}

extension ChooseWalletCoordinator: ChooseWalletNavigator {

    func toMain(wallet: Wallet) {
        navigation?.toMain(wallet: wallet)
    }

    func toChooseWallet() {
        let viewModel = ChooseWalletViewModel(navigator: self)
        let vc = ChooseWallet(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func toCreateNewWallet() {
        start(coordinator: CreateNewWalletCoordinator(navigationController: navigationController, navigator: self))
    }

    func toRestoreWallet() {
        start(coordinator: RestoreWalletCoordinator(navigationController: navigationController, navigator: self))
    }

}
