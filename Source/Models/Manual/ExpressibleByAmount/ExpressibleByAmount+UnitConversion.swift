//
//  ExpressibleByAmount+UnitConversion.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-28.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

internal extension ExpressibleByAmount {
    static func toQa(_ value: Magnitude) -> Magnitude {
        return express(value, in: .qa)
    }
}

// Unit conversion
public extension ExpressibleByAmount {

    var value: Magnitude {
        return valueMeasured(in: unit)
    }

    func valueMeasured(in unit: Unit) -> Magnitude {
        return Self.express(qa, in: unit)
    }

    static func express(_ input: Magnitude, in unit: Unit) -> Magnitude {
        let exponentDiff = abs(unit.exponent - self.unit.exponent)
        let powerFactor = BigNumber(10).power(exponentDiff)  //pow(10, Double(exponentDiff))
        // Instead of doing input / pow(10, Double(unit.exponent - Self.unit.exponent))
        // which may result in precision loss we perform either division or multiplication
        if unit > self.unit {
            return input / powerFactor
        } else {
            return input * powerFactor
        }
    }

    var inZil: Zil {
        return Zil(qa: qa)
    }

    var inLi: Li {
        return Li(qa: qa)
    }

    var inQa: Qa {
        return Qa(qa: qa)
    }
}

public extension ExpressibleByAmount {
    func `as`<E>(_ type: E.Type) -> E where E: ExpressibleByAmount {
        return E.init(valid: qa)
    }

    func `as`<B>(_ type: B.Type) throws -> B where B: Bound & ExpressibleByAmount {
        return try B.init(qa: qa)
    }
}
