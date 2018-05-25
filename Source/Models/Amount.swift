//
//  Amount.swift
//  ZilliqaSDKTests
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Amount {
    public let amount: Double
    public init?(double amount: Double) {
        guard amount >= 0 else { return nil } // Amount must not be negative
        self.amount = amount
    }
}

extension Amount: ExpressibleByFloatLiteral {}
public extension Amount {
    /// This `ExpressibleByFloatLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(floatLiteral value: Double) {
        guard let amount = Amount(double: value) else {
            fatalError("The `Double` value used to create amount was invalid")
        }
        self = amount
    }
}

extension Amount: ExpressibleByIntegerLiteral {}
public extension Amount {
    /// This `ExpressibleByIntegerLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(integerLiteral value: Int) {
        guard let amount = Amount(double: Double(value)) else {
            fatalError("The `Int` value used to create amount was invalid")
        }
        self = amount
    }
}

