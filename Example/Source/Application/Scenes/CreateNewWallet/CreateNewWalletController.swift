//
//  CreateNewWalletController.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

final class CreateNewWalletController: SingleContentViewController<CreateNewWalletView, CreateNewWalletViewModel> {

    // MARK: - Initializers
    init(viewModel: CreateNewWalletViewModel) {
        let contentView = CreateNewWalletView()
        super.init(view: contentView, viewModel: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func input() -> Input {
        return Input()
    }
}
