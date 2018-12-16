//
//  Amount.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import BigInt

public struct Amount: ExpressibleByAmount {
    public static let totalSupply: Value = 21_000_000_000 // 21 billion Zillings is the total supply

    public let value: Value

    public init(value amount: Value) throws {
        guard amount >= 0 else {
            print("☣️ AmountError.amountWasNegative")
            throw AmountError.amountWasNegative
        }
        guard amount <= Amount.totalSupply else {
            print("☣️ AmountError.amountExceededTotalSupply")
            throw AmountError.amountExceededTotalSupply
        }
        self.value = amount
    }
}

public extension Amount {
    func asGasPrice() -> GasPrice {
        do {
            return try Amount.express(value: value, in: GasPrice.self)
        } catch {
            fatalError("Incorrect implementation, check the unit conversion")
        }
    }
}
