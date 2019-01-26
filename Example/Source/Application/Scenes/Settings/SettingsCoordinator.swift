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
