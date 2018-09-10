//
//  Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

public protocol ViewStyling {
    var height: CGFloat? { get }
    var backgroundColor: UIColor { get }
}

extension ViewStyling where Self: Makeable, Self.View.Empty == Self.View, Self.View.Style == Self {
    func make() -> View {
        return View(style: self)
    }
}

protocol Makeable: ViewStyling {
    associatedtype View: Styling & StaticEmptyInitializable & UIView
}

public class ViewStyle: ViewStyling {
    public let height: CGFloat?
    public let backgroundColor: UIColor
    public init(height: CGFloat? = CGFloat.defaultHeight, backgroundColor: UIColor) {
        self.height = height
        self.backgroundColor = backgroundColor
    }
}

public protocol Styling {
    associatedtype Style: ViewStyling
    func apply(style: Style)
}


extension Styling where Self: UIView, Self: StaticEmptyInitializable, Self.Empty == Self {

    init(style: Style) {
        self = Self.createEmpty()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = style.backgroundColor
        if let height = style.height {
            self.height(height)
        }
        apply(style: style)
    }
}

extension Styling where Self: UIView, Self: StaticEmptyInitializable, Self.Empty == Self, Style: ExpressibleByStringLiteral, Self.Style.StringLiteralType == String  {

    public init(stringLiteral value: String) {
        let style = Style.init(stringLiteral: value)
        self = Self.init(style: style)
    }
}
