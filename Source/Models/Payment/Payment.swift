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
