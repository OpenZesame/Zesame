//
//  GasPrice.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2018-12-14.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct GasPrice: ExpressibleByAmount, AdjustableUpperbound, Lowerbound {
    public typealias Magnitude = Qa.Magnitude
    public static let minMagnitude: Magnitude = 1_000_000_000

    /// By default GasPrice has an upperbound of 10 Zil, this can be changed.
    public static let maxMagnitudeDefault: Magnitude = Zil(valid: 10).inQa.magnitude
    public static var maxMagnitude = maxMagnitudeDefault {
        willSet {
            guard newValue >= minMagnitude else {
                fatalError("Cannot set maxMagnitude to less than minMagnitude")
            }
        }
    }
    public static let unit: Unit = .qa
    public let magnitude: Magnitude

    public init(valid magnitude: Magnitude) {
        do {
            self.magnitude = try GasPrice.validate(magnitude: magnitude)
        } catch {
            fatalError("Invalid magnitude passed: `\(magnitude)`, error: `\(error)`")
        }
    }
}

public extension GasPrice {
    var amount: Qa.Magnitude {
        return magnitude
    }
}

public extension GasPrice {
    static var minInLiAsInt: Int {
        return Int(GasPrice.min.inLi.magnitude)
    }
}
