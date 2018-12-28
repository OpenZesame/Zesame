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

public protocol ExpressibleByLiterals {
    var asDouble: Double { get }
    init(double: Double)
    init(int: Int)
}

public extension ExpressibleByLiterals {
    public init(int: Int) {
        self.init(double: Double(int))
    }
}

extension Double: ExpressibleByLiterals {
    public var asDouble: Double { return self }
    public init(double: Double) {
        self = double
    }
}

public protocol ExpressibleByAmount: Numeric, Codable, Comparable, CustomStringConvertible, CustomDebugStringConvertible, ExpressibleByFloatLiteral, ExpressibleByStringLiteral where Magnitude: ExpressibleByLiterals & ExpressibleByFloatLiteral {

    static var unit: Unit { get }
    static var minMagnitude: Magnitude { get }
    static var min: Self { get }
    static var maxMagnitude: Magnitude { get }
    static var max: Self { get }
    var magnitude: Magnitude { get }
    init(magnitude: Magnitude)

    init(_ validating: Magnitude) throws
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

    init?<T>(exactly source: T) where T : BinaryInteger {
        guard let magnitude = Magnitude(exactly: source) else {
            return nil
        }
        do {
            self = try Self(magnitude)
        } catch {
            return nil
        }
    }
}

public extension ExpressibleByAmount where Magnitude == Zil.Magnitude {
    static var maxMagnitude: Magnitude {
        return Zil.express(Zil.Magnitude(double: 21_000_000_000), in: Self.unit)
    }
}

public extension ExpressibleByAmount {

    static var minMagnitude: Magnitude { return 0 }
    static var min: Self { return Self(magnitude: minMagnitude) }

    static var max: Self { return Self(magnitude: maxMagnitude) }

    var unit: Unit { return Self.unit }

    func valueMeasured(in unit: Unit) -> Magnitude {
        return Self.express(magnitude, in: unit)
    }

    static func express(_ input: Magnitude, in unit: Unit) -> Magnitude {
        let double: Double = input.asDouble / pow(10, Double(unit.exponent - Self.unit.exponent))
        return Magnitude(double: double)
    }
}

public extension ExpressibleByAmount {
    static var powerOf: String {
        return unit.powerOf
    }
}

public enum AmountError: Swift.Error {
    case tooSmall(minMagnitudeIs: Double)
    case tooLarge(maxMagnitudeIs: Double)
    case nonNumericString
}

public extension ExpressibleByAmount {

    static func validate(magnitude: Magnitude) throws -> Magnitude {
        guard magnitude >= minMagnitude else {
            throw AmountError.tooSmall(minMagnitudeIs: minMagnitude.asDouble)
        }

        guard magnitude <= maxMagnitude else {
            throw AmountError.tooLarge(maxMagnitudeIs: maxMagnitude.asDouble)
        }

        return magnitude
    }

    init(_ unvalidatedMagnitude: Magnitude) throws {
        let validated = try Self.validate(magnitude: unvalidatedMagnitude)
        self.init(magnitude: validated)
    }

    init(_ unvalidatedMagnitude: Int) throws {
        try self.init(Magnitude(int: unvalidatedMagnitude))
    }

    init(_ unvalidatedMagnitude: String) throws {
        guard let unvalidatedDouble = Double(unvalidatedMagnitude) else {
            throw AmountError.nonNumericString
        }
        try self.init(Magnitude(double: unvalidatedDouble))
    }

    init(floatLiteral double: Double) {
        do {
            try self = Self.init(Magnitude(double: double))
        } catch {
            fatalError("The `Double` value (`\(double)`) passed was invalid, error: \(error)")
        }
    }

    init(integerLiteral int: Int) {
        do {
            try self = Self(int)
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

public extension ExpressibleByAmount where Magnitude == Zil.Magnitude {
    var inZil: Zil {
        return Zil(magnitude: valueMeasured(in: .zil))
    }

    init(zil: Zil) throws {
        try self.init(zil.valueMeasured(in: Self.unit))
    }
}

public extension ExpressibleByAmount where Magnitude == Li.Magnitude {
    var inLi: Li {
        return Li(magnitude: valueMeasured(in: .li))
    }

    init(li: Li) throws {
        try self.init(li.valueMeasured(in: Self.unit))
    }
}

public extension ExpressibleByAmount where Magnitude == Qa.Magnitude {
    var inQa: Qa {
        return Qa(magnitude: valueMeasured(in: .qa))
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

    private static func oper(_ lhs: Self, _ rhs: Self, calc: (Magnitude, Magnitude) -> Magnitude) -> Self {
        return Self.init(magnitude: calc(lhs.magnitude, rhs.magnitude))
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
    public typealias Magnitude = Double
    public static let unit: Unit = .zil
    public static var totalSupply = Zil.max
    public let magnitude: Magnitude

    public init(magnitude: Magnitude) {
        do {
            self.magnitude = try Zil.validate(magnitude: magnitude)
        } catch {
            fatalError("Invalid magnitude passed: `\(magnitude)`, error: `\(error)`")
        }
    }
}

public struct Li: ExpressibleByAmount {
    public typealias Magnitude = Double
    public static let unit: Unit = .li
    public let magnitude: Magnitude

    public init(magnitude: Magnitude) {
        do {
            self.magnitude = try Li.validate(magnitude: magnitude)
        } catch {
            fatalError("Invalid magnitude passed")
        }
    }
}

public struct Qa: ExpressibleByAmount {
    public typealias Magnitude = Double
    public static let unit: Unit = .qa
    public let magnitude: Magnitude

    public init(magnitude: Magnitude) {
        do {
            self.magnitude = try Qa.validate(magnitude: magnitude)
        } catch {
            fatalError("Invalid magnitude passed")
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

// CustomStringConvertiblbe
public extension ExpressibleByAmount {
    var description: String {
        return "\(magnitude) \(unit.name) (E\(unit.exponent))"
    }
}


// CustomDebugStringConvertible
public extension ExpressibleByAmount {
    var debugDescription: String {
        return "\(description) (value in zil: \(valueMeasured(in: .zil)))"
    }
}
