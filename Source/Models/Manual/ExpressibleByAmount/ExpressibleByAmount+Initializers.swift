//
//  ExpressibleByAmount+Initializers.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-28.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation


public extension ExpressibleByAmount {

    static func validate(magnitude: Magnitude) throws -> Magnitude {
        try AnyLowerbound(self).throwErrorIfNotWithinBounds(magnitude)
        try AnyUpperbound(self).throwErrorIfNotWithinBounds(magnitude)
        return magnitude
    }

    static func validate(magnitude string: String) throws -> Magnitude {
        guard let magnitude = Magnitude(string) else {
            throw AmountError<Self>.nonNumericString
        }
        return try validate(magnitude: magnitude)
    }

}

public extension ExpressibleByAmount where Self: Bound {


    init(magnitude: Magnitude) throws {
        let validated = try Self.validate(magnitude: magnitude)
        self.init(valid: validated)
    }

    init(magnitude int: Int) throws {
        do {
            try self = Self.init(magnitude: Magnitude(int))
        } catch {
            fatalError("The `Int` value (`\(int)`) passed was invalid, error: \(error)")
        }
    }

    init(floatLiteral double: Double) {
        do {
            try self = Self.init(magnitude: double)
        } catch {
            fatalError("The `Double` value (`\(double)`) passed was invalid, error: \(error)")
        }
    }

    init(integerLiteral int: Int) {
        do {
            try self = Self.init(magnitude: Magnitude(int))
        } catch {
            fatalError("The `Int` value (`\(int)`) passed was invalid, error: \(error)")
        }
    }

    init(magnitude string: String) throws {
        try self.init(magnitude: try Self.validate(magnitude: string))
    }

    init(stringLiteral string: String) {
        do {
            try self = Self(magnitude: string)
        } catch {
            fatalError("The `String` value (`\(string)`) passed was invalid, error: \(error)")
        }
    }

    init(zil zilString: String) throws {
        try self.init(zil: try Zil(zil: zilString))
    }
    init(li liString: String) throws {
        try self.init(li: try Li(li: liString))
    }
    init(qa qaString: String) throws {
        try self.init(qa: try Qa(qa: qaString))
    }

    init<UE>(_ unbound: UE) throws where UE: Unbound & ExpressibleByAmount {
        try self.init(magnitude: unbound.valueMeasured(in: Self.unit))
    }

    init(zil: Zil) throws {
        // using init:unbound
        try self.init(zil)
    }

    init(li: Li) throws {
        // using init:unbound
        try self.init(li)
    }

    init(qa: Qa) throws {
        // using init:unbound
        try self.init(qa)
    }
}

public extension ExpressibleByAmount where Self: Unbound {

    init(magnitude: Magnitude) {
        self.init(valid: magnitude)
    }

    init(magnitude int: Int) {
        self.init(magnitude: Magnitude(int))
    }

    init(floatLiteral double: Double) {
        self.init(magnitude: double)
    }

    init(integerLiteral int: Int) {
        self.init(magnitude: int)
    }

    init(magnitude string: String) throws {
        self.init(magnitude: try Self.validate(magnitude: string))
    }

    init(stringLiteral string: String) {
        do {
            try self = Self(magnitude: string)
        } catch {
            fatalError("The `String` value (`\(string)`) passed was invalid, error: \(error)")
        }
    }

    init<UE>(_ unbound: UE) where UE: Unbound & ExpressibleByAmount {
        self.init(magnitude: unbound.valueMeasured(in: Self.unit))
    }

    init(zil: Zil) {
        // using init:unbound
        self.init(zil)
    }

    init(li: Li) {
        // using init:unbound
        self.init(li)
    }

    init(qa: Qa) {
        // using init:unbound
        self.init(qa)
    }

    init(zil zilString: String) throws {
        self.init(zil: try Zil(zil: zilString))
    }
    init(li liString: String) throws {
        self.init(li: try Li(li: liString))
    }
    init(qa qaString: String) throws {
        self.init(qa: try Qa(qa: qaString))
    }
}
