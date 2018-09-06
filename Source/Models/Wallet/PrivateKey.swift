//
//  PrivateKey.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import EllipticCurve
import BigInt

//// TODO: Remove this when UInt256 makes internal function `arc4random256` public
//public extension UInt256 {
//    static func arc4random256() -> UInt256 {
//        return arc4random_uniform(UInt256.max)
//    }
//}

public struct PrivateKey {
    let randomBigNumber: BigNumber

    public init?(randomBigNumber: BigNumber) {
        guard randomBigNumber < Secp256k1.Order else { return nil }
        self.randomBigNumber = randomBigNumber
    }
}

public extension PrivateKey {
    init() {
        var privateKey: PrivateKey?
        while privateKey == nil {
            privateKey = PrivateKey(randomBigNumber: BigUInt.randomInteger(withMaximumWidth: 256))
        }
        self = privateKey!
    }

    init?(string: String) {
        guard let bigNumber = BigNumber(string: string) else { return nil }
        self.init(randomBigNumber: bigNumber)
    }
}

extension PrivateKey: ExpressibleByStringLiteral {}
public extension PrivateKey {
    init(stringLiteral value: String) {
        guard let fromString = PrivateKey(string: value) else { fatalError("String not convertible to PrivateKey") }
        self = fromString
    }
}

public extension PrivateKey {
    func toHexString() -> String {
        return "0x\(randomBigNumber.toHexString())"
    }
}
