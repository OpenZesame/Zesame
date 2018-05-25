//
//  Address.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Address {
    public let address: Double

    public init(double: Double) {
        self.address = double
    }
}

// MARK: - ExpressibleByFloatLiteral
extension Address: ExpressibleByFloatLiteral {}
public extension Address {
    /// This `ExpressibleByFloatLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(floatLiteral value: Double) {
        self.init(double: value)
    }
}

// MARK: - ExpressibleByStringLiteral
extension Address: ExpressibleByStringLiteral {}
public extension Address {
    /// This `ExpressibleByStringLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(stringLiteral value: String) {
        guard let addressFromLiteral = Address(string: value) else {
            fatalError("The value used to create address was invalid")
        }
        self = addressFromLiteral
    }
}

public extension Address {
    init?(string: String) {
        guard let double = Double(string) else { return nil } // Addresses should start with "0x"
        self.init(double: double)
    }
}
