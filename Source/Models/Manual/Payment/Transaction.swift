//
//  Transaction.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2018-10-07.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

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

public struct Version {
    public let value: UInt32

    public init(value: UInt32) {
        self.value = value
    }

    public init(network: Network = .default, transactionVersion: UInt32 = 1) {
        self.init(value: network.chainId << 16 + transactionVersion)
    }
}

extension Version: Codable {}
extension Version: Equatable {}
extension Version: ExpressibleByIntegerLiteral {}
public extension Version {
    public init(integerLiteral value: UInt32) {
        self.init(value: value)
    }
}

public extension Version {
    static var `default`: Version {
        return Version()
    }
}

public struct Transaction {
    let version: Version
    let payment: Payment
    let data: String
    let code: String

    init(payment: Payment, version: Version = .default, data: String = "", code: String = "") {
        self.version = version
        self.payment = payment
        self.data = data
        self.code = code
    }
}
