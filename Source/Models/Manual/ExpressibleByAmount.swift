//
//  ExpressibleByAmount.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-14.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import BigInt

public enum AmountError: Int, Swift.Error, Equatable {
    case nonNumericString
    case amountWasNegative
    case amountExceededTotalSupply
}

public protocol ExpressibleByAmount: ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, Comparable, Codable, CustomStringConvertible {
    typealias Number = Int
    var amount: Number { get }
    init(number: Number) throws
    init(string: String) throws
}

extension ExpressibleByAmount {
    public init(string: String) throws {
        guard let bigNumber = BigNumber(decimalString: string) else {
            throw AmountError.nonNumericString
        }

        guard bigNumber <= BigNumber(Amount.totalSupply) else {
            throw AmountError.amountExceededTotalSupply
        }

        try self.init(number: Number(bigNumber))
    }
}

// MARK: - Comparable
extension ExpressibleByAmount {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.amount < rhs.amount
    }
}

// MARK: - Encodable
extension ExpressibleByAmount {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(amount.description)
    }
}

// MARK: - Decodable
extension ExpressibleByAmount {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string: string)
    }
}

// MARK: - ExpressibleByIntegerLiteral
extension ExpressibleByAmount {
    /// This `ExpressibleByIntegerLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(integerLiteral value: Int) {
        do {
            try self = Self(number: value)
        } catch {
            fatalError("The `Int` value (`\(value)`) used to create amount was invalid, error: \(error)")
        }
    }
}

// MARK: - ExpressibleByStringLiteral
extension ExpressibleByAmount {
    /// This `ExpressibleByStringLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(stringLiteral value: String) {
        do {
            guard let number = Int(value) else {
                throw AmountError.nonNumericString
            }
            try self = Self(number: number)
        } catch {
            fatalError("The `String` value (`\(value)`) used to create amount was invalid, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
extension ExpressibleByAmount {
    public var description: String {
        return amount.description
    }
}
