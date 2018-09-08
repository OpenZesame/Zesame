//
//  UITextField+Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

extension UITextField: EmptyInitializable, Styling, StaticEmptyInitializable, ExpressibleByStringLiteral {

    public static func createEmpty() -> UITextField {
        return UITextField(frame: .zero)
    }

    public struct Style: ExpressibleByStringLiteral {
        let placeholder: String
        let textColor: UIColor
        let backgroundColor: UIColor
        let font: UIFont

        init(_ placeholder: String, font: UIFont = .default, textColor: UIColor = .defaultText, backgroundColor: UIColor = .white) {
            self.placeholder = placeholder
            self.font = font
            self.textColor = textColor
            self.backgroundColor = backgroundColor
        }

        public init(stringLiteral placeholder: String) {
            self.init(placeholder)
        }
    }

    convenience init(style: Style) {
        self.init(frame: .zero)
        apply(style: style)
        translatesAutoresizingMaskIntoConstraints = false
    }

    public func apply(style: Style) {
        placeholder = style.placeholder
        textColor = style.textColor
        backgroundColor = style.backgroundColor
        font = style.font
    }
}
