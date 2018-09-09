//
//  ChooseWalletNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift
import ZilliqaSDK

final class ChooseWalletNavigator: Navigator {
    private weak var navigationController: UINavigationController?
    private weak var appNavigator: AppNavigator?

    init(appNavigator: AppNavigator, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.appNavigator = appNavigator
    }

    deinit {
        print("💣 ChooseWalletNavigator")
    }
}

extension ChooseWalletNavigator {
    enum Destination {
        case chooseWallet
        case chosen(wallet: Wallet)
        case createNewWallet
        case restoreWallet
    }

    func start() {
        navigate(to: .chooseWallet)
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .chosen(let chosenWallet):
            appNavigator?.navigate(to: AppNavigator.Destination.chosen(wallet: chosenWallet))
        case .chooseWallet:
            navigationController?.pushViewController(
                ChooseWalletController(viewModel: ChooseWalletViewModel(navigate(to:))),
                animated: true
            )
        case .createNewWallet:
            let navigator = CreateNewWalletNavigator(chooseWalletNavigator: self, navigationController: navigationController)
            navigator.start()
        case .restoreWallet:
            let navigator = RestoreWalletNavigator(chooseWalletNavigator: self, navigationController: navigationController)
            navigator.start()
            //            return RestoreWalletController(viewModel: RestoreWalletViewModel(navigate(to:)))
        }
    }
}
