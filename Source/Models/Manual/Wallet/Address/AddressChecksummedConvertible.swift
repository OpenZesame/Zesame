//
//  AddressChecksummedConvertible.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-12.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation
import EllipticCurveKit

public protocol AddressChecksummedConvertible: HexStringConvertible {
    var checksummedAddress: AddressChecksummed { get }
    init(hexString: HexStringConvertible) throws
}

public extension AddressChecksummedConvertible {
    init(string: String) throws {
        try self.init(hexString: try HexString(string))
    }


    init(compressedHash: Data) throws {
        try self.init(string: compressedHash.toHexString())
    }

    init(publicKey: PublicKey, network: Network) {
        let system = EllipticCurveKit.Zilliqa(network)
        let compressedHash = system.compressedHash(from: publicKey)
        do {
            try self.init(compressedHash: compressedHash)
        } catch {
            fatalError("Incorrect implementation, using `publicKey:network` initializer should never result in error: `\(error)`")
        }
    }

    init(keyPair: KeyPair, network: Network) {
        self.init(publicKey: keyPair.publicKey, network: network)
    }

    init(privateKey: PrivateKey, network: Network = .default) {
        let keyPair = KeyPair(private: privateKey)
        self.init(keyPair: keyPair, network: network)
    }
}

public extension AddressChecksummedConvertible {
    var hexString: HexString { return checksummedAddress.checksummed }
}
