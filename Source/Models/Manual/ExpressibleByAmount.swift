//
//  ExpressibleByAmount.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-14.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import BigInt

public enum Unit: Int, Equatable, CustomStringConvertible {
    case zil = 0
    case li = -6
    case qa = -12
}

public extension Unit {
    var exponent: Int {
        return rawValue
    }

    var powerOf: String {
        return "10^\(exponent)"
    }

    var name: String {
        switch self {
        case .zil: return "zil"
        case .li: return "li"
        case .qa: return "qa"
        }
    }
}

public extension Unit {
    var description: String {
        return name
    }
}

public protocol ExpressibleByAmount: Numeric, Comparable, CustomStringConvertible, CustomDebugStringConvertible, ExpressibleByFloatLiteral, ExpressibleByStringLiteral where Magnitude == Significand {


    typealias Significand = Double

    static var unit: Unit { get }
    static var minSignificand: Significand { get }
    static var min: Self { get }
    static var maxSignificand: Significand { get }
    static var max: Self { get }
    var significand: Significand { get }
    init(significand: Significand)

    init(_ validating: Significand) throws
    init(_ validating: Int) throws
    init(_ validating: String) throws

    var inLi: Li { get }
    var inZil: Zil { get }
    var inQa: Qa { get }
    init(zil: Zil) throws
    init(li: Li) throws
    init(qa: Qa) throws
    init(zil zilString: String) throws
    init(li liString: String) throws
    init(qa qaString: String) throws
}

public extension Li {
     var inLi: Li { return self }
}

public extension Zil {
    var inZil: Zil { return self }
}

public extension Qa {
    var inQa: Qa { return self }
}

public extension ExpressibleByAmount {
    var magnitude: Magnitude {
        return significand
    }

    init?<T>(exactly source: T) where T : BinaryInteger {
        guard let significand = Significand(exactly: source) else {
            return nil
        }
        do {
            self = try Self(significand)
        } catch {
            return nil
        }
    }
}

public extension ExpressibleByAmount {

    static var minSignificand: Significand { return 0 }
    static var min: Self { return Self(significand: minSignificand) }

    static var maxSignificand: Significand {
        return Zil.express(21_000_000_000, in: Self.unit)
    }

    static var max: Self { return Self(significand: maxSignificand) }

    var unit: Unit { return Self.unit }

    func valueMeasured(in unit: Unit) -> Significand {
        return Self.express(significand, in: unit)
    }

    static func express(_ input: Significand, in unit: Unit) -> Significand {
        return input / pow(10, Significand(unit.exponent - Self.unit.exponent))
    }
}

public extension ExpressibleByAmount {
    static var powerOf: String {
        return unit.powerOf
    }
}

public enum AmountError: Swift.Error {
    case tooSmall(minSignificandIs: Double)
    case tooLarge(maxSignificandIs: Double)
    case nonNumericString
}

public extension ExpressibleByAmount {

    static func validate(significand: Significand) throws -> Significand {
        guard significand >= minSignificand else {
            throw AmountError.tooSmall(minSignificandIs: minSignificand)
        }

        guard significand <= maxSignificand else {
            throw AmountError.tooLarge(maxSignificandIs: maxSignificand)
        }

        return significand
    }

    init(_ unvalidatedSignificand: Significand) throws {
        let validated = try Self.validate(significand: unvalidatedSignificand)
        self.init(significand: validated)
    }

    init(_ unvalidatedSignificand: Int) throws {
      try self.init(Significand(unvalidatedSignificand))
    }

    init(_ unvalidatedSignificand: String) throws {
        guard let unvalidatedDouble = Significand(unvalidatedSignificand) else {
            throw AmountError.nonNumericString
        }
        try self.init(unvalidatedDouble)
    }

    init(floatLiteral double: Double) {
        do {
            try self = Self(double)
        } catch {
            fatalError("The `Double` value (`\(double)`) passed was invalid, error: \(error)")
        }
    }

    init(integerLiteral int: Int) {
        do {
            try self = Self(Significand(int))
        } catch {
            fatalError("The `Int` value (`\(int)`) passed was invalid, error: \(error)")
        }
    }

    init(stringLiteral string: String) {
        do {
            try self = Self(string)
        } catch {
            fatalError("The `String` value (`\(string)`) passed was invalid, error: \(error)")
        }
    }
}

public extension ExpressibleByAmount {
    init(zil: Zil) throws {
        try self.init(zil.valueMeasured(in: Self.unit))
    }

    init(li: Li) throws {
        try self.init(li.valueMeasured(in: Self.unit))
    }

    init(qa: Qa) throws {
        try self.init(qa.valueMeasured(in: Self.unit))
    }
}


public extension ExpressibleByAmount {
    init(zil zilString: String) throws {
        try self.init(zil: try Zil(zilString))
    }

    init(li liString: String) throws {
        try self.init(li: try Li(liString))
    }

    init(qa qaString: String) throws {
        try self.init(qa: try Qa(qaString))
    }
}


public extension ExpressibleByAmount {

    private static func oper(_ lhs: Self, _ rhs: Self, calc: (Significand, Significand) -> Significand) -> Self {
        return Self.init(significand: calc(lhs.significand, rhs.significand))
    }

    static func * (lhs: Self, rhs: Self) -> Self {
        return oper(lhs, rhs) { $0 * $1 }
    }

    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        return oper(lhs, rhs) { $0 + $1 }
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        return oper(lhs, rhs) { $0 - $1 }
    }

    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
}

public struct Zil: ExpressibleByAmount {
    public static let unit: Unit = .zil
    public static var totalSupply = Zil.max
    public let significand: Significand

    public init(significand: Significand) {
        do {
            self.significand = try Zil.validate(significand: significand)
        } catch {
            fatalError("Invalid significand passed")
        }
    }
}

public struct Li: ExpressibleByAmount {
    public static let unit: Unit = .li
    public let significand: Significand

    public init(significand: Significand) {
        do {
            self.significand = try Li.validate(significand: significand)
        } catch {
            fatalError("Invalid significand passed")
        }
    }
}

public struct Qa: ExpressibleByAmount {

    public static let unit: Unit = .qa
    public let significand: Significand

    public init(significand: Significand) {
        do {
            self.significand = try Qa.validate(significand: significand)
        } catch {
            fatalError("Invalid significand passed")
        }
    }
}

// Comparable
public extension ExpressibleByAmount {

    static func == (lhs: Self, rhs: Self) -> Bool {
        let unitUsedForComparision: Unit = .qa
        return lhs.valueMeasured(in: unitUsedForComparision) == rhs.valueMeasured(in: unitUsedForComparision)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        let unitUsedForComparision: Unit = .qa
        return lhs.valueMeasured(in: unitUsedForComparision) < rhs.valueMeasured(in: unitUsedForComparision)
    }
}

public func == <A, B>(lhs: A, rhs: B) -> Bool where A: ExpressibleByAmount, B: ExpressibleByAmount {
    return lhs.inQa == rhs.inQa
}

public func <= <A, B>(lhs: A, rhs: B) -> Bool where A: ExpressibleByAmount, B: ExpressibleByAmount {
    return lhs.inQa <= rhs.inQa
}

public func >= <A, B>(lhs: A, rhs: B) -> Bool where A: ExpressibleByAmount, B: ExpressibleByAmount {
    return lhs.inQa >= rhs.inQa
}

public func != <A, B>(lhs: A, rhs: B) -> Bool where A: ExpressibleByAmount, B: ExpressibleByAmount {
    return lhs.inQa != rhs.inQa
}

public func > <A, B>(lhs: A, rhs: B) -> Bool where A: ExpressibleByAmount, B: ExpressibleByAmount {
    return lhs.inQa > rhs.inQa
}

public func < <A, B>(lhs: A, rhs: B) -> Bool where A: ExpressibleByAmount, B: ExpressibleByAmount {
    return lhs.inQa < rhs.inQa
}

public func - <A, B>(lhs: A, rhs: B) -> A where A: ExpressibleByAmount, B: ExpressibleByAmount {
    return try! lhs - A.init(rhs.valueMeasured(in: B.unit))
}

// CustomStringConvertiblbe
public extension ExpressibleByAmount {
    var description: String {
        return "\(significand) \(unit.name) (E\(unit.exponent))"
    }
}


// CustomDebugStringConvertible
public extension ExpressibleByAmount {
    var debugDescription: String {
        return "\(description) (value in zil: \(valueMeasured(in: .zil)))"
    }
}

public extension ExpressibleByAmount {
    var inZil: Zil {
        return Zil(significand: valueMeasured(in: .zil))
    }

    var inLi: Li {
        return Li(significand: valueMeasured(in: .li))
    }

    var inQa: Qa {
        return Qa(significand: valueMeasured(in: .qa))
    }
}
