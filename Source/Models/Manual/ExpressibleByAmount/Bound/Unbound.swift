//
//  Unbound.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-30.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public protocol Unbound: NoLowerbound & NoUpperbound {
    associatedtype Magnitude: Comparable & Numeric

    // "Designated" init, check bounds
    init(qa: Magnitude)

    /// Most important "convenience" init
    init(value: Magnitude)

    /// Various convenience inits
    init(value double: Double)
    init(value int: Int)
    init(value string: String) throws
    init<UE>(other: UE) where UE: ExpressibleByAmount & Unbound
    init(zil: Zil)
    init(li: Li)
    init(qa: Qa)
    init(zil: String) throws
    init(li: String) throws
    init(qa: String) throws
}

public extension ExpressibleByAmount where Self: Unbound {
    /// Most important "convenience" init
    init(value: Magnitude) {
        self.init(qa: Self.toQa(value))
    }

    init(valid: Magnitude) {
        self.init(value: valid)
    }
}

public extension ExpressibleByAmount where Self: Unbound {

    init(value double: Double) {
        self.init(value: Magnitude(double))
    }

    init(value int: Int) {
        self.init(value: Magnitude(int))
    }


    init(value string: String) throws {
        self.init(value: try Self.validate(value: string))
    }
}

public extension ExpressibleByAmount where Self: Unbound {
    init<UE>(other: UE) where UE: ExpressibleByAmount & Unbound {
        self.init(qa: other.qa)
    }

    init(zil: Zil) {
        self.init(other: zil)
    }

    init(li: Li) {
        self.init(other: li)
    }

    init(qa: Qa) {
        self.init(other: qa)
    }
}

public extension ExpressibleByAmount where Self: Unbound {
    init(zil zilString: String) throws {
        self.init(zil: try Zil(value: zilString))
    }

    init(li liString: String) throws {
        self.init(li: try Li(value: liString))
    }

    init(qa qaString: String) throws {
        self.init(qa: try Qa(value: qaString))
    }
}

// MARK: - ExpressibleByFloatLiteral
public extension ExpressibleByAmount where Self: Unbound {
    init(floatLiteral double: Double) {
        self.init(value: double)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension ExpressibleByAmount where Self: Unbound {
    init(integerLiteral int: Int) {
        self.init(value: int)
    }
}

// MARK: - ExpressibleByStringLiteral
public extension ExpressibleByAmount where Self: Unbound {
    init(stringLiteral string: String) {
        do {
            try self = Self(value: string)
        } catch {
            fatalError("The `String` value (`\(string)`) passed was invalid, error: \(error)")
        }
    }
}
