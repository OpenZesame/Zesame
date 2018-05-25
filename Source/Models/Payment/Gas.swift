//
//  Gas.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Gas {
    public let price: Price
    public let limit: Limit

    public init(price: Price, limit: Limit) {
        self.price = price
        self.limit = limit
    }

    public struct Price {
        public let price: Double
        public init?(double price: Double) {
            guard price > 0 else { return nil }
            self.price = price
        }
    }

    public struct Limit {
        public let limit: Double
        public init?(double limit: Double) {
            guard limit > 0 else { return nil }
            self.limit = limit
        }
    }
}

public extension Gas {
    init?(rawPrice: Double, rawLimit: Double) {
        guard
            let price = Price(double: rawPrice),
            let limit = Limit(double: rawLimit)
            else { return nil }
        self.init(price: price, limit: limit)
    }
}

extension Gas.Price: ExpressibleByFloatLiteral {}
public extension Gas.Price {
    /// This `ExpressibleByFloatLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(floatLiteral value: Double) {
        guard let price = Gas.Price(double: value) else {
            fatalError("The `Double` value used to create price was invalid")
        }
        self = price
    }
}

extension Gas.Price: ExpressibleByIntegerLiteral {}
public extension Gas.Price {
    /// This `ExpressibleByIntegerLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(integerLiteral value: Int) {
        guard let price = Gas.Price(double: Double(value)) else {
            fatalError("The `Int` value used to create price was invalid")
        }
        self = price
    }
}


extension Gas.Limit: ExpressibleByFloatLiteral {}
public extension Gas.Limit {
    /// This `ExpressibleByFloatLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(floatLiteral value: Double) {
        guard let limit = Gas.Limit(double: value) else {
            fatalError("The `Double` value used to create limit was invalid")
        }
        self = limit
    }
}

extension Gas.Limit: ExpressibleByIntegerLiteral {}
public extension Gas.Limit {
    /// This `ExpressibleByIntegerLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(integerLiteral value: Int) {
        guard let limit = Gas.Limit(double: Double(value)) else {
            fatalError("The `Int` value used to create limit was invalid")
        }
        self = limit
    }
}

