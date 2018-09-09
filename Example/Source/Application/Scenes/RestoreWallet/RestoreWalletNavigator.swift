//
//  RestoreWalletNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import ZilliqaSDK

final class RestoreWalletNavigator {


    private weak var navigationController: UINavigationController?
    private weak var chooseWalletNavigator: ChooseWalletNavigator?

    init(chooseWalletNavigator: ChooseWalletNavigator, navigationController: UINavigationController?) {

        self.navigationController = navigationController
        self.chooseWalletNavigator = chooseWalletNavigator
    }

    deinit {
        print("💣 RestoreWalletNavigator")
    }
}

// MARK: - Navigator
extension RestoreWalletNavigator: Navigator {
    enum Destination {
        case restore
        case restored(Wallet)
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .restored(let wallet):
            chooseWalletNavigator?.navigate(to: ChooseWalletNavigator.Destination.chosen(wallet: wallet))
        case .restore:
            let viewModel = RestoreWalletViewModel(navigate(to:))
            let vc = RestoreWalletController(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func start() {
        navigate(to: .restore)
    }
}
