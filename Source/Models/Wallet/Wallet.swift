//
//  Wallet.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

public struct Wallet {
    public let keyPair: KeyPair
    public let address: Address

    public init(keyPair: KeyPair, address: Address) {
        self.keyPair = keyPair
        self.address = address
    }
}


public extension Wallet {

    init(keyPair: KeyPair, network: Network) {
        self.init(keyPair: keyPair, address:  Address(keyPair: keyPair, network: network))
    }

    init?(privateKeyHex: String, network: Network = .default) {
        guard let keyPair = KeyPair(privateKeyHex: privateKeyHex) else { return nil }
        self.init(keyPair: keyPair, network: network)
    }
}

extension Wallet: CustomStringConvertible {}
public extension Wallet {
    var description: String {
        return """
            address: '\(address)'
            publicKey: '\(keyPair.publicKey)'
        """
    }
}
