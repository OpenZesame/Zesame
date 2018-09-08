//
//  OpenWalletController.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

final class OpenWalletController: SingleContentViewController<OpenWalletView, OpenWalletViewModel> {

    init(viewModel: OpenWalletViewModel) {
        let contentView = OpenWalletView()
        super.init(view: contentView, viewModel: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func input() -> Input {
        return Input(createNewTrigger: contentView.createNewWalletButton.rx.tap.asDriver(), restoreTrigger: contentView.restoreWalletButton.rx.tap.asDriver())
    }
}
