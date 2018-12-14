//
//  Amount.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import BigInt

public struct Amount: ExpressibleByAmount {
    public typealias Number = Int

    public static let totalSupply: Number = 21_000_000_000 // 21 billion Zillings is the total supply

    public let amount: Number

    public init(number amount: Number) throws {
        guard amount >= 0 else { throw AmountError.amountWasNegative }
        guard amount <= Amount.totalSupply else { throw AmountError.amountExceededTotalSupply }
        self.amount = amount
    }
}
