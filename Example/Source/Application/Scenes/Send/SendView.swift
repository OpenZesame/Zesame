//
//  SendView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - SendView
final class SendView: StackViewOwningView, StackViewStyling {

    lazy var addressLabel: UILabel = ""
    lazy var sendButton: UIButton = "Send"


    lazy var stackViewStyle: UIStackView.Style = [addressLabel, sendButton, .spacer]
}

extension SendView: SingleContentView {
    typealias ViewModel = SendViewModel
    func populate(with viewModel: ViewModel.Output) -> [Disposable] { 
        return [ /* viewModel.drive(someView.rx.) */ ] 
    }
}
