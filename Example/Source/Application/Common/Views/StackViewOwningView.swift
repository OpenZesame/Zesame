//
//  StackViewOwningView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

public class StackViewOwningView: UIView {
    //    var stackViewStyle: Style.StackView { fatalError("Abstract, override me please") }
    func makeStackView() -> UIStackView {
        fatalError("override me")
    }

    lazy var stackView: UIStackView = {
        return makeStackView()
    }()

    public init() {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.edgesToSuperview()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
