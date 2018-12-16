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
    typealias Value = Double

    /// The unit used to measure the amount. If the `Self` is `Amount` to send to address then the exponent is
    /// the default of `0`, meaning that we measure in whole Zillings. But we might measure `GasPrice` in units
    /// being worth less, being measure in units of 10^-12, then this property will have the value `-12`
    static var exponent: Int { get }

    var value: Value { get }
    init(value: Value) throws
    init(string: String) throws
}

public extension ExpressibleByAmount {
    static var exponent: Int { return 0 }

    /// The decimal exponentiation of the exponent, i.e. the value resulting from 10^exponent
    /// see `exponent` property for more info.
    static var powerFactor: Double {
        return pow(10, Double(exponent))
    }
}

// MARK: - Initializers
public extension ExpressibleByAmount {
    init(string: String) throws {
        guard
            let significand = Value(string),
            case let value = significand * Self.powerFactor
            else {
                print("☣️ AmountError.nonNumericString")
            throw AmountError.nonNumericString
        }

        print("Value: \(value), significand: \(significand)")

        guard value <= Amount.totalSupply else {
            print("☣️ AmountError.amountExceededTotalSupply")
            throw AmountError.amountExceededTotalSupply
        }

        try self.init(value: significand)
    }

    init(_ integer: Int) throws {
        try self.init(value: Value(integer))
    }
}

// MARK: - Comparable
public extension ExpressibleByAmount {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.value < rhs.value
    }
}

// MARK: - Encodable
public extension ExpressibleByAmount {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.description)
    }
}

// MARK: - Decodable
public extension ExpressibleByAmount {
     init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string: string)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension ExpressibleByAmount {
    /// This `ExpressibleByIntegerLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    init(integerLiteral integerValue: Int) {
        do {
            try self = Self(integerValue)
        } catch {
            fatalError("The `Int` value (`\(integerValue)`) used to create amount was invalid, error: \(error)")
        }
    }
}

// MARK: - ExpressibleByStringLiteral
public extension ExpressibleByAmount {
    /// This `ExpressibleByStringLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    init(stringLiteral stringValue: String) {
        do {
            guard let value = Value(stringValue) else {
                throw AmountError.nonNumericString
            }
            try self = Self(value: value)
        } catch {
            fatalError("The `String` value (`\(stringValue)`) used to create amount was invalid, error: \(error)")
        }
    }
}


// MARK: - CustomStringConvertible
public extension ExpressibleByAmount {
    var description: String {
        return Int(value).description
    }
}
