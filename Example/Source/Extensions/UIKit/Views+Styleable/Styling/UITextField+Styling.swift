//
//  UITextField+Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import TinyConstraints

extension UITextField: EmptyInitializable, Styling, StaticEmptyInitializable, ExpressibleByStringLiteral {

    public static func createEmpty() -> UITextField {
        return UITextField(frame: .zero)
    }

    public final class Style: ViewStyle, Makeable, ExpressibleByStringLiteral {

        typealias View = UITextField

        let placeholder: String?
        let text: String?
        let textColor: UIColor
        let font: UIFont

        init(_ placeholder: String?, text: String? = nil, height: CGFloat? = CGFloat.defaultHeight, font: UIFont = .default, textColor: UIColor = .defaultText, backgroundColor: UIColor = .white) {
            self.placeholder = placeholder
            self.text = text
            self.font = font
            self.textColor = textColor
            super.init(height: height, backgroundColor: backgroundColor)
        }

        public convenience init(stringLiteral placeholder: String) {
            self.init(placeholder)
        }
    }

    public func apply(style: Style) {
        placeholder = style.placeholder
        textColor = style.textColor
        backgroundColor = style.backgroundColor
        font = style.font
        text = style.text
    }
}

public extension CGFloat {
    static var defaultHeight: CGFloat { return 44 }
}
