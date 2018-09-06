//
//  Nonce.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Nonce {
    public let nonce: Int
    public init(nonce: Int = 0) {
        self.nonce = nonce
    }
}

public extension Nonce {
    static var zero: Nonce {
        return Nonce()
    }
}
