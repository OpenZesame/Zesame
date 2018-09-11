//
//  Wallet.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import EllipticCurveKit

public typealias KeyPair = EllipticCurveKit.KeyPair<Secp256k1>
public typealias PublicKey = EllipticCurveKit.PublicKey<Secp256k1>
public typealias Signature = EllipticCurveKit.Signature<Secp256k1>
public typealias Signer = EllipticCurveKit.AnyKeySigner<Schnorr<Secp256k1>>
public typealias Address = EllipticCurveKit.PublicAddress<Zilliqa>
public typealias Network = EllipticCurveKit.Zilliqa.Network

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

public extension Wallet {
    init?(privateKeyHex: String) {
        guard let keyPair = KeyPair(privateKeyHex: privateKeyHex) else { return nil }
        self.init(keyPair: keyPair)
    }
}

extension Wallet: CustomStringConvertible {}
public extension Wallet {
    var description: String {
        return """
        address: '\(address.address)'
        """
    }
}
