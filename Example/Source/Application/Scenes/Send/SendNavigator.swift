//
//  SendNavigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ZilliqaSDK

// MARK: - SendNavigator
struct SendNavigator {

    private weak var navigationController: UINavigationController?
    private let wallet: Wallet

    init(navigationController: UINavigationController, wallet: Wallet) {
        self.navigationController = navigationController
        self.wallet = wallet
    }
}

extension SendNavigator: Navigator {

    enum Destination {
        case send
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .send:
            navigationController?.pushViewController(
                SendController(
                    viewModel: SendViewModel(navigate(to:), service: DefaultZilliqaService(wallet: wallet))
                ),
                animated: true
            )
        }
    }

    func start() {
        navigate(to: .send)
    }

}
