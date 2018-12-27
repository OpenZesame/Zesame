//
//  GasPrice.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2018-12-14.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct GasPrice: AmountConvertible {
    public static let minAmount: Qa = 1_000_000_000
    public static let maxAmount = Qa.max
    public let amount: Qa

    public init(amount: Qa) {
        self.amount = amount
    }
}

public extension GasPrice {
    static var minInLi: Int {
        return Int(minAmount.inLi.significand)
    }
}
