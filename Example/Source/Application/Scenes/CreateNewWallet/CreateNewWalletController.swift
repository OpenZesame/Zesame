//
//  CreateNewWalletController.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public final class CreateNewWalletController: SingleContentViewController<CreateNewWalletView, CreateNewWalletViewModel> {

    public init(viewModel: CreateNewWalletViewModel) {
        let contentView = CreateNewWalletView()
        super.init(view: contentView, viewModel: viewModel)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func input() -> Input {
        return Input()
    }

    public override func bound(output: Output) {
        print("nothing to do")
    }

}
