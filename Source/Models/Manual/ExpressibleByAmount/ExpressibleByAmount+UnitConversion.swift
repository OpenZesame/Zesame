//
//  ExpressibleByAmount+UnitConversion.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-28.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

// Unit conversion
public extension ExpressibleByAmount {
    func valueMeasured(in unit: Unit) -> Magnitude {
        return Self.express(magnitude, in: unit)
    }

    static func express(_ input: Magnitude, in unit: Unit) -> Magnitude {
        return Magnitude.init(floatLiteral: input / pow(10, Double(unit.exponent - Self.unit.exponent)))
    }

    var inZil: Zil {
        return Zil(valid: valueMeasured(in: .zil))
    }

    var inLi: Li {
        return Li(valid: valueMeasured(in: .li))
    }

    var inQa: Qa {
        return Qa(valid: valueMeasured(in: .qa))
    }
}
