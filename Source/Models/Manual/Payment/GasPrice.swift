//
//  GasPrice.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2018-12-14.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct GasPrice: ExpressibleByAmount, AdjustableUpperbound, AdjustableLowerbound {

    public typealias Magnitude = Qa.Magnitude
    public static let unit: Unit = .qa

    public let qa: Magnitude

    /// By default GasPrice has a lowerobund of 1000 Li, i.e 1 000 000 000 Qa, this can be changed.
    public static let minMagnitudeDefault: Magnitude = Li(value: 1000).qa
    public static var minMagnitude = minMagnitudeDefault {
        willSet {
            guard newValue <= maxMagnitude else {
                fatalError("Cannot set minMagnitude to greater than maxMagnitude, max: \(maxMagnitude), new min: \(newValue) (old: \(minMagnitude)")
            }
        }
    }

    /// By default GasPrice has an upperbound of 10 Zil, this can be changed.
    public static let maxMagnitudeDefault: Magnitude = Zil(value: 10).qa
    public static var maxMagnitude = maxMagnitudeDefault {
        willSet {
            guard newValue >= minMagnitude else {
                fatalError("Cannot set maxMagnitude to less than minMagnitude, min: \(minMagnitude), new max: \(newValue) (old: \(maxMagnitude)")
            }
        }
    }

    public init(qa: Magnitude) throws {
        self.qa = try GasPrice.validate(value: qa)
    }
}
