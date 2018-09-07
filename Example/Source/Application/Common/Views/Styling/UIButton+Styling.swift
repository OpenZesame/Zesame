//
//  UIButton+Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

public extension UIButton {

    public struct Style {

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

        static func button(_ text: String) -> Style {
            return Style(text)
        }
    }

    func apply(style: Style) {
        setTitle(style.text, for: UIControlState())
        setTitleColor(style.textColor, for: UIControlState())
        titleLabel?.font = style.font
        backgroundColor = style.backgroundColor
    }

    convenience init(style: Style) {
        self.init(type: .custom)
        apply(style: style)
        translatesAutoresizingMaskIntoConstraints = false
    }

    static func make(_ title: String) -> UIButton {
        return UIButton(style: Style(title))
    }
}
