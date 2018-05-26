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
    init(addressDouble address: Double, amountDouble amount: Double, priceDouble price: Double, limitDouble limit: Double) throws {
        let address = try Address(double: address)
        let amount = try Amount(double: amount)
        let gas = try Gas(rawPrice: price, rawLimit: limit)
        self.init(to: address, amount: amount, gas: gas)
    }

    init(addressString address: String, amountDouble amount: Double, priceDouble price: Double, limitDouble limit: Double) throws {
        let address = try Address(string: address)
        let amount = try Amount(double: amount)
        let gas = try Gas(rawPrice: price, rawLimit: limit)
        self.init(to: address, amount: amount, gas: gas)
    }
}
