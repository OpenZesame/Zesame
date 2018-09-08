//
//  UIStackView+Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit



extension UIStackView: Styling {

    public struct Style: ExpressibleByArrayLiteral {
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

        public init(arrayLiteral views: UIView...) {
            self.init(views)
        }
    }

    public func apply(style: Style) {
        axis = style.axis
        alignment = style.alignment
        distribution = style.distribution
    }

    convenience init(style: Style) {
        self.init(arrangedSubviews: style.views)
        apply(style: style)
        translatesAutoresizingMaskIntoConstraints = false
    }
}
