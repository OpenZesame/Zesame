//
//  UIStackView+Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

public extension UIStackView {

    public struct Style {
        let axis: NSLayoutConstraint.Axis
        let alignment: UIStackView.Alignment
        let distribution: UIStackView.Distribution
        let views: [UIView]
        init(_ views: [UIView], axis: NSLayoutConstraint.Axis = .vertical, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fillProportionally) {
            self.views = views
            self.axis = axis
            self.alignment = alignment
            self.distribution = distribution
        }
    }

    convenience init(style: Style) {
        self.init(arrangedSubviews: style.views)
        axis = style.axis
        alignment = style.alignment
        distribution = style.distribution
        translatesAutoresizingMaskIntoConstraints = false
    }

    static func make(_ views: [UIView], axis: NSLayoutConstraint.Axis = .vertical) -> UIStackView {
        return UIStackView(style: Style(views, axis: axis))
    }
}
