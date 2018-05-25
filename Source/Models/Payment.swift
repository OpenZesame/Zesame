//
//  Payment.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Payment {
    public let recipient: Address
    public let amount: Amount
    public let gas: Gas

    public init(to recipient: Address, amount: Amount, gas: Gas) {
        self.recipient = recipient
        self.amount = amount
        self.gas = gas
    }

    public struct Amount {
        public let amount: Double
        public init?(double amount: Double) {
            guard amount >= 0 else { return nil } // Amount must not be negative
            self.amount = amount
        }
    }
}

// MARK: - Convenience Initializer
public extension Payment {
    init?(addressDouble address: Double, amountDouble amount: Double, priceDouble price: Double, limitDouble limit: Double) {
        guard
            let amount = Amount(double: amount),
            let gas = Gas(rawPrice: price, rawLimit: limit)
            else { return nil }
        self.init(to: Address(double: address), amount: amount, gas: gas)
    }

    init?(addressString address: String, amountDouble amount: Double, priceDouble price: Double, limitDouble limit: Double) {
        guard
            let address = Address(string: address),
            let amount = Amount(double: amount),
            let gas = Gas(rawPrice: price, rawLimit: limit)
            else { return nil }
        self.init(to: address, amount: amount, gas: gas)
    }
}

extension Payment.Amount: ExpressibleByFloatLiteral {}
public extension Payment.Amount {
    /// This `ExpressibleByFloatLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(floatLiteral value: Double) {
        guard let amount = Payment.Amount(double: value) else {
            fatalError("The `Double` value used to create amount was invalid")
        }
        self = amount
    }
}

extension Payment.Amount: ExpressibleByIntegerLiteral {}
public extension Payment.Amount {
    /// This `ExpressibleByIntegerLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(integerLiteral value: Int) {
        guard let amount = Payment.Amount(double: Double(value)) else {
            fatalError("The `Int` value used to create amount was invalid")
        }
        self = amount
    }
}

