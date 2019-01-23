//
//  Network.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-12.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation
import EllipticCurveKit

/// ⚠️ THE VALUES ARE NOT CONFIRMED
public enum Network: UInt32, Decodable {
    case mainnet = 1
    case testnet = 2
}

// MARK: - Encodable
public extension Network {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(chainId)
    }
}

// MARK: - Decodable
public extension Network {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let chainId = try container.decode(UInt32.self)
        guard let network = Network(rawValue: chainId) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Received new chain id: \(chainId), you need to add this to the enum `Network`")
        }
        self = network
    }
}

public extension Network {
    static var `default`: Network {
        return .mainnet
    }
}

public extension Network {

    var chainId: UInt32 {
        print("⚠️ Using uncofirmed chain id. Verify that this is the correct chain id before launch.")
        return rawValue
    }

    func compressedHashForAddressFromPublicKey(_ publicKey: PublicKey) -> Data {
        // Actually using Bitcoin `mainnet` settings for address formatting. As of not not related to `Zesame.Network`
        let system = EllipticCurveKit.Zilliqa(EllipticCurveKit.Zilliqa.Network.mainnet)
        return system.compressedHash(from: publicKey)
    }
}
