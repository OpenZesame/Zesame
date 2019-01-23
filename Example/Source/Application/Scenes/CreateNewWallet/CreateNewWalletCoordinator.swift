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

final class CreateNewWalletCoordinator {

    private weak var navigationController: UINavigationController?
    private weak var navigator: ChooseWalletNavigator?

    init(navigationController: UINavigationController?, navigator: ChooseWalletNavigator) {
        self.navigationController = navigationController
        self.navigator = navigator
    }
}

extension CreateNewWalletCoordinator: AnyCoordinator {
    func start() {
        toCreateWallet()
    }
}

protocol CreateNewWalletNavigator: AnyObject {
    func toCreateWallet()
    func toMain(wallet: Wallet)
}

extension CreateNewWalletCoordinator: CreateNewWalletNavigator {

    func toMain(wallet: Wallet) {
        navigator?.toMain(wallet: wallet)
    }

    func toCreateWallet() {
        let viewModel = CreateNewWalletViewModel(navigator: self, service: AppDelegate.zilliqaSerivce.rx)
        let vc = CreateNewWallet(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}
