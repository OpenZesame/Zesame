//
//  StackViewOwningView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

protocol StackViewStyling {
    var stackViewStyle: UIStackView.Style { get }
}

class StackViewOwningView: UIView {

    lazy var stackView: UIStackView = {
        guard let styling = self as? StackViewStyling else { fatalError("Your subclass of `StackViewOwningView` should conform to protocol `StackViewStyling`") }
        return UIStackView(style: styling.stackViewStyle)
    }()

    init() {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
