//
//  OpenWalletController.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

public final class OpenWalletController: SingleContentViewController<OpenWalletView, OpenWalletViewModel> {

    public init(viewModel: OpenWalletViewModel) {
        let contentView = OpenWalletView()
        super.init(view: contentView, viewModel: viewModel)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func input() -> Input {
        return Input(createNewTrigger: contentView.createNewWalletButton.rx.tap.asDriver(), restoreTrigger: contentView.restoreWalletButton.rx.tap.asDriver())
    }

    public override func bound(output: Output) {
        print("nothing to do with bound")
    }
}
