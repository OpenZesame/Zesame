//
//  Amount.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import BigInt

public struct Amount {
    public static let totalSupply: BigNumber = 21000000000 // 21 billion Zillings is the total supply

    public let amount: BigNumber

    public init(number amount: BigNumber) throws {
        guard amount >= 0 else { throw Error.amountWasNegative }
        guard amount <= Amount.totalSupply else { throw Error.amountExceededTotalSupply }
        self.amount = amount
    }

    public init(decimalString: String) throws {
        guard let number = BigNumber(decimalString: decimalString) else {
            throw Error.nonNumericString
        }
        try self.init(number: number)
    }

    public enum Error: Int, Swift.Error, Equatable {
        case nonNumericString
        case amountWasNegative
        case amountExceededTotalSupply
    }
}

extension Amount: ExpressibleByIntegerLiteral {}
public extension Amount {
    /// This `ExpressibleByIntegerLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(integerLiteral value: Int) {
        do {
            try self = Amount(number: BigNumber(value))
        } catch {
            fatalError("The `Int` value (`\(value)`) used to create amount was invalid, error: \(error)")
        }
    }
}

extension Amount: ExpressibleByStringLiteral {}
public extension Amount {
    /// This `ExpressibleByStringLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(stringLiteral value: String) {
        do {
            guard let number = BigNumber(decimalString: value) else {
                throw Error.nonNumericString
            }
            try self = Amount(number: number)
        } catch {
            fatalError("The `String` value (`\(value)`) used to create amount was invalid, error: \(error)")
        }
    }
}

public extension Amount {
    var asDecimalString: String {
        return amount.asDecimalString()
    }
}
