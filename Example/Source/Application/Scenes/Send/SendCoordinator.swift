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

// MARK: - SendNavigator
final class SendCoordinator {

    private weak var navigationController: UINavigationController?
    private let wallet: Observable<Wallet>

    init(navigationController: UINavigationController, wallet: Observable<Wallet>) {
        self.navigationController = navigationController
        self.wallet = wallet
    }
}

extension SendCoordinator: AnyCoordinator {
    func start() {
        toSend()
    }
}

protocol SendNavigator: AnyObject {
    func toSend()
}

extension SendCoordinator: SendNavigator {

    func toSend() {
        navigationController?.pushViewController(
            Send(
                viewModel: SendViewModel(navigator: self, wallet: wallet, service: AppDelegate.zilliqaSerivce.rx)
            ),
            animated: true
        )
    }
}
