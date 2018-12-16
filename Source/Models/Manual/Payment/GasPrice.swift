//
//  GasPrice.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2018-12-14.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct GasPrice: ExpressibleByAmount {
    public static let exponent: Int = -12
    
    public enum Error: Swift.Error {
        case tooSmall(passed: Value, shouldBeMin: Value)
    }
    public let value: Value
    public init(value gasPrice: Value) throws {
        let minimum = GasPrice.minimumValue
        guard gasPrice >= minimum else {
            throw Error.tooSmall(passed: gasPrice, shouldBeMin: minimum)
        }

        // verify less than total supply
        let inAmount = try GasPrice.express(value: gasPrice, in: Amount.self)
        guard inAmount.value <= Amount.totalSupply else {
            throw AmountError.amountExceededTotalSupply

        }
        self.value = gasPrice
    }
}

public extension GasPrice {
    static var minimum: GasPrice {
        return try! GasPrice(value: minimumValue)
    }
    static let minimumValue: Value = 100
}

public extension GasPrice {
    func asAmount() -> Amount {
        do {
            return try GasPrice.express(value: value, in: Amount.self)
        } catch {
            fatalError("Incorrect implementation, check the unit conversion")
        }
    }
}

public extension ExpressibleByAmount {
    static func express<Unit>(value: Value, in unit: Unit.Type) throws -> Unit where Unit: ExpressibleByAmount {
        return try Unit(value: value * powerFactor/Unit.powerFactor)
    }
}
