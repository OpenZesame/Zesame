//
//  Wallet.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import SwiftCrypto // renamed to EllipticCurveKit in next release

public typealias KeyPair = SwiftCrypto.KeyPair<Secp256k1>
public typealias Address = SwiftCrypto.PublicAddress<Zilliqa>
public typealias Network = SwiftCrypto.Zilliqa.Network

public struct Wallet {
    public let keyPair: KeyPair
    public let address: Address
    public let balance: Amount
    public let nonce: Nonce
    public let network: Network

    public init(keyPair: KeyPair, network: Network = .testnet, balance: Amount = 0, nonce: Nonce = 0) {
        self.keyPair = keyPair
        self.address = Address(keyPair: keyPair, system: Zilliqa(network))
        self.balance = balance
        self.network = network
        self.nonce = nonce
    }
}

extension Wallet: CustomStringConvertible {}
public extension Wallet {
    public var description: String {
        return """
        address: '\(address.address)'
        """
    }
}


