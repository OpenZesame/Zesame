//
//  UILabel+Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

extension UILabel: Styling, StaticEmptyInitializable, ExpressibleByStringLiteral {

    public static func createEmpty() -> UILabel {
        return UILabel()
    }

    public final class Style: ViewStyle, Makeable, ExpressibleByStringLiteral {

        typealias View = UILabel

        let text: String?
        let textColor: UIColor
        let font: UIFont
        let numberOfLines: Int

        init(_ text: String? = nil, height: CGFloat? = CGFloat.defaultHeight, font: UIFont = .default, textColor: UIColor = .black, numberOfLines: Int = 1, backgroundColor: UIColor = .white) {
            self.text = text
            self.textColor = textColor
            self.font = font
            self.numberOfLines = numberOfLines
            super.init(height: height, backgroundColor: backgroundColor)
        }

        public convenience init(stringLiteral title: String) {
            self.init(title)
        }
    }

    public func apply(style: Style) {
        text = style.text
        font = style.font
        textColor = style.textColor
        backgroundColor = style.backgroundColor
        numberOfLines = style.numberOfLines
    }
}
