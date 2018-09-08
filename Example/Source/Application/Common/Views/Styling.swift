//
//  Styling.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

public protocol Styling {
    associatedtype Style
    func apply(style: Style)
}

extension Styling where Self: UIView, Self: StaticEmptyInitializable, Self.Empty == Self {

    init(style: Style) {
        self = Self.createEmpty()
        apply(style: style)
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension Styling where Self: UIView, Self: StaticEmptyInitializable, Self.Empty == Self, Style: ExpressibleByStringLiteral, Self.Style.StringLiteralType == String  {

    public init(stringLiteral value: String) {
        let style = Style.init(stringLiteral: value)
        self = Self.init(style: style)
    }
}
