//
//  SendController.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import Foundation

final class SendController: SingleContentViewController<SendView, SendViewModel> {

    init(viewModel: SendViewModel) {
        let contentView = SendView()
        super.init(view: contentView, viewModel: viewModel)
    }

    required init?(coder: NSCoder) { interfaceBuilderSucks }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
    }

    override func input() -> Input {
        return Input(sendTrigger: contentView.sendButton.rx.tap.asDriver())
    }
}

