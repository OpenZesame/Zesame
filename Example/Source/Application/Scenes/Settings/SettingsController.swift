//
//  SettingsController.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import Foundation

final class SettingsController: SingleContentViewController<SettingsView, SettingsViewModel> {

    init(viewModel: SettingsViewModel) {
        let contentView = SettingsView()
        super.init(view: contentView, viewModel: viewModel)
    }

    required init?(coder: NSCoder) { interfaceBuilderSucks }

    override func input() -> Input {
        return Input(
            removeWalletTrigger: contentView.removeWalletButton.rx.tap.asDriver()
        )
    }
}

