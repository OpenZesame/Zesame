//
//  SettingsNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct SettingsNavigator {

    private weak var navigationController: UINavigationController?

    private let chooseWallet: () -> Void

    init(navigationController: UINavigationController?, chooseWallet: @escaping () -> Void) {
        self.navigationController = navigationController
        self.chooseWallet = chooseWallet
    }
}

// MARK: - Navigator
extension SettingsNavigator: Navigator {
    enum Destination {
        case settings
        case chooseWallet
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .settings:
            navigationController?.pushViewController(
                Settings(
                    viewModel: SettingsViewModel(navigate(to:))
                ),
                animated: true
            )
        case .chooseWallet:
            Unsafe︕！Cache.deleteWallet()
           chooseWallet()
        }
    }

    func start() {
        navigate(to: .settings)
    }
}
