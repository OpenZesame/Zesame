//
//  GasPrice.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2018-12-14.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct GasPrice: ExpressibleByAmount {
    public enum Error: Swift.Error {
        case tooSmall(passed: Number, shouldBeMin: Number)
    }
    public let amount: Number
    public init(number amount: Number) throws {
        let minimum = GasPrice.minimumAmount
        guard amount >= minimum else { throw Error.tooSmall(passed: amount, shouldBeMin: minimum) }
        self.amount = amount
    }
}
public extension GasPrice {
    static var minimum: GasPrice {
        return try! GasPrice(number: minimumAmount)
    }
    static let minimumAmount: Number = 100
}
