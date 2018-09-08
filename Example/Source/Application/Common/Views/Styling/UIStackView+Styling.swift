//
//  UIStackView+Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit



extension UIStackView: Styling, StaticEmptyInitializable {

    public static func createEmpty() -> UIStackView {
        return UIStackView(arrangedSubviews: [])
    }

    public final class Style: ViewStyle, ExpressibleByArrayLiteral {
        let axis: NSLayoutConstraint.Axis
        let alignment: UIStackView.Alignment
        let distribution: UIStackView.Distribution
        let views: [UIView]

        init(
            _ views: [UIView],
            axis: NSLayoutConstraint.Axis = .vertical,
            alignment: UIStackView.Alignment = .fill,
            distribution: UIStackView.Distribution = .fill
        ) {
            self.views = views
            self.axis = axis
            self.alignment = alignment
            self.distribution = distribution

            // background color is irrelevant for stackviews
            super.init(height: nil, backgroundColor: .red)
        }

        public convenience init(arrayLiteral views: UIView...) {
            self.init(views)
        }
    }

    public func apply(style: Style) {
        style.views.reversed().forEach { self.insertArrangedSubview($0, at: 0) }
        axis = style.axis
        alignment = style.alignment
        distribution = style.distribution
    }
}
