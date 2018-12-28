//
//  ExpressibleByAmount.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-14.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public protocol ExpressibleByAmount: Numeric,
Codable,
Comparable,
CustomStringConvertible,
CustomDebugStringConvertible,
ExpressibleByFloatLiteral,
ExpressibleByStringLiteral
where Magnitude == Double {

    // These are the two most important properties of the `ExpressibleByAmount` protocol,
    // the unit in which the value - the magnitude is measured.
    static var unit: Unit { get }
    var magnitude: Magnitude { get }

    static var minMagnitude: Magnitude { get }
    static var min: Self { get }
    static var maxMagnitude: Magnitude { get }
    static var max: Self { get }

    // Convenience translations
    var inLi: Li { get }
    var inZil: Zil { get }
    var inQa: Qa { get }

    // The "designated" initializer
    init(magnitude: Magnitude)

    // Convenience initializers
    init(_ validating: Magnitude) throws
    init(_ validating: Int) throws
    init(_ validating: String) throws
    init(zil: Zil) throws
    init(li: Li) throws
    init(qa: Qa) throws
    init(zil zilString: String) throws
    init(li liString: String) throws
    init(qa qaString: String) throws
}




public extension ExpressibleByAmount where Magnitude == Zil.Magnitude {
    static var maxMagnitude: Magnitude {
        return Zil.express(Zil.Magnitude(floatLiteral: 21_000_000_000), in: Self.unit)
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
        return Magnitude.init(floatLiteral: input / pow(10, Double(unit.exponent - Self.unit.exponent)))
    }

    init(_ unvalidatedMagnitude: String) throws {
        guard let unvalidatedDouble = Double(unvalidatedMagnitude) else {
            throw AmountError.nonNumericString
        }
        try self.init(Magnitude.init(floatLiteral: unvalidatedDouble))
    }

    init(floatLiteral double: Double) {
        do {
            try self = Self.init(Magnitude.init(floatLiteral: double))
        } catch {
            fatalError("The `Double` value (`\(double)`) passed was invalid, error: \(error)")
        }
    }
}

public extension ExpressibleByAmount {
    static var powerOf: String {
        return unit.powerOf
    }
}



public extension ExpressibleByAmount {

    static func validate(magnitude: Magnitude) throws -> Magnitude {
        guard magnitude >= minMagnitude else {
            throw AmountError.tooSmall(minMagnitudeIs: minMagnitude)
        }

        guard magnitude <= maxMagnitude else {
            throw AmountError.tooLarge(maxMagnitudeIs: maxMagnitude)
        }

        return magnitude
    }

    init(_ unvalidatedMagnitude: Magnitude) throws {
        let validated = try Self.validate(magnitude: unvalidatedMagnitude)
        self.init(magnitude: validated)
    }

    init(_ unvalidatedMagnitude: Int) throws {
        try self.init(Magnitude(unvalidatedMagnitude))
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
