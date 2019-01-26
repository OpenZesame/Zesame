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

final class RestoreWalletCoordinator: AnyCoordinator {

    private weak var navigationController: UINavigationController?
    private weak var navigator: ChooseWalletNavigator?

    init(navigationController: UINavigationController?, navigator: ChooseWalletNavigator) {
        self.navigationController = navigationController
        self.navigator = navigator
    }
}

public protocol RestoreWalletNavigator: AnyObject {
    func toRestoreWallet()
    func toMain(restoredWallet: Wallet)
}

// MARK: - Navigator
extension RestoreWalletCoordinator: RestoreWalletNavigator {

    func toMain(restoredWallet: Wallet) {
        navigator?.toMain(wallet: restoredWallet)
    }

    func toRestoreWallet() {
        let viewModel = RestoreWalletViewModel(navigator: self, service: AppDelegate.zilliqaSerivce.rx)
        let vc = RestoreWallet(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func start() {
        toRestoreWallet()
    }
}
