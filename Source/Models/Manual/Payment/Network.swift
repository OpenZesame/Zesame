//
//  Network.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-12.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation
import EllipticCurveKit

public enum Network: UInt32 {
    case mainnet = 1
    case testnet = 2
}

public extension Network {
    static var `default`: Network {
        return .mainnet
    }
}

public extension Network {

    var chainId: UInt32 { return rawValue }

    func compressedHashForAddressFromPublicKey(_ publicKey: PublicKey) -> Data {
        // Actually using Bitcoin `mainnet` settings for address formatting. As of not not related to `Zesame.Network`
        let system = EllipticCurveKit.Zilliqa(EllipticCurveKit.Zilliqa.Network.mainnet)
        return system.compressedHash(from: publicKey)
    }
}
