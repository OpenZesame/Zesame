//
//  Bound.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-30.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public protocol Bound {
    associatedtype Magnitude: Comparable & Numeric

    // "Designated" init, check bounds
    init(qa: Magnitude) throws

    /// Most important "convenience" init
    init(value: Magnitude) throws

    /// Various convenience inits
    init(value double: Double) throws
    init(value int: Int) throws
    init(value string: String) throws
    init<UE>(other: UE) throws where UE: ExpressibleByAmount & Unbound
    init(zil: Zil) throws
    init(li: Li) throws
    init(qa: Qa) throws
    init(zil: String) throws
    init(li: String) throws
    init(qa: String) throws
}

public extension ExpressibleByAmount where Self: Bound {
    /// Most important "convenience" init
    init(value: Magnitude) throws {
        try self.init(qa: Self.toQa(value))
    }

    init(valid: Magnitude) {
        do {
            try self.init(value: valid)
        } catch {
            fatalError("The value `valid` (`\(valid)`) passed was invalid, error: \(error)")
        }
    }
}

public extension ExpressibleByAmount where Self: Bound {

    init(value double: Double) throws {
        try self.init(value: Magnitude(double))
    }

    init(value int: Int) throws {
        try self.init(value: Magnitude(int))
    }

    init(value string: String) throws {
        try self.init(value: try Self.validate(value: string))
    }
}

public extension ExpressibleByAmount where Self: Bound {
    init<UE>(other: UE) throws where UE: ExpressibleByAmount & Unbound {
        try self.init(qa: other.qa)
    }

    init(zil: Zil) throws {
        try self.init(other: zil)
    }

    init(li: Li) throws {
        try self.init(other: li)
    }

    init(qa: Qa) throws {
        try self.init(other: qa)
    }
}

public extension ExpressibleByAmount where Self: Bound {
    init(zil zilString: String) throws {
        try self.init(zil: try Zil(value: zilString))
    }

    init(li liString: String) throws {
        try self.init(li: try Li(value: liString))
    }

    init(qa qaString: String) throws {
        try self.init(qa: try Qa(value: qaString))
    }
}

// MARK: - ExpressibleByFloatLiteral
public extension ExpressibleByAmount where Self: Bound {
    init(floatLiteral double: Double) {
        do {
            try self.init(value: double)
        } catch {
            fatalError("The `Double` value (`\(double)`) passed was invalid, error: \(error)")
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension ExpressibleByAmount where Self: Bound {
    init(integerLiteral int: Int) {
        do {
            try self.init(value: int)
        } catch {
            fatalError("The `Int` value (`\(int)`) passed was invalid, error: \(error)")
        }
    }
}

// MARK: - ExpressibleByStringLiteral
public extension ExpressibleByAmount where Self: Bound {
    init(stringLiteral string: String) {
        do {
            try self = Self(value: string)
        } catch {
            fatalError("The `String` value (`\(string)`) passed was invalid, error: \(error)")
        }
    }
}


public extension Bound where Self: AdjustableLowerbound, Self: AdjustableUpperbound {
    static func restoreDefaultBounds() {
        restoreDefaultMin()
        restoreDefaultMax()
    }
}
