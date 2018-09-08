//
//  UIButton+Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

extension UIButton: EmptyInitializable, Styling, StaticEmptyInitializable, ExpressibleByStringLiteral {

    public static func createEmpty() -> UIButton {
        return UIButton(type: .custom)
    }

    public struct Style: ExpressibleByStringLiteral {

        let text: String
        let textColor: UIColor
        let backgroundColor: UIColor
        let font: UIFont

        init(_ text: String, font: UIFont = .default, textColor: UIColor = .black, backgroundColor: UIColor = .green) {
            self.text = text
            self.textColor = textColor
            self.font = font
            self.backgroundColor = backgroundColor
        }

        public init(stringLiteral title: String) {
            self.init(title)
        }
    }

    public func apply(style: Style) {
        setTitle(style.text, for: UIControlState())
        setTitleColor(style.textColor, for: UIControlState())
        titleLabel?.font = style.font
        backgroundColor = style.backgroundColor
    }
}
