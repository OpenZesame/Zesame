//
//  ZilAmount.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct ZilAmount: AmountConvertible {
    public static let minAmount = Zil.min
    public static let maxAmount = Zil.max

    public let amount: Zil

    public init(amount: Zil) {
        self.amount = amount
    }
}
