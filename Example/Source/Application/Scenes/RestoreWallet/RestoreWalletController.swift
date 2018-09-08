//
//  RestoreWalletController.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

final class RestoreWalletController: SingleContentViewController<RestoreWalletView, RestoreWalletViewModel> {

    init(viewModel: RestoreWalletViewModel) {
        let contentView = RestoreWalletView()
        super.init(view: contentView, viewModel: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func input() -> Input {
        return Input(
            privateKey: contentView.privateKeyField.rx.text.orEmpty.asDriver(),
            restoreTrigger: contentView.restoreWalletButton.rx.tap.asDriver()
        )
    }
}
