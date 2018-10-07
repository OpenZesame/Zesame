//
//  Wallet.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

public struct Wallet {
    public let keystore: Keystore
    public let address: Address

    public init(keystore: Keystore, address: Address) {
        self.keystore = keystore
        self.address = address
    }
}

extension Address: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(checksummedHex)
    }
}

extension Address: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        try self.init(hexString: hexString)
    }
}

extension Wallet: Encodable {
    public enum CodingKeys: String, CodingKey {
        case keystore, address
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keystore, forKey: .keystore)
        try container.encode(address, forKey: .address)
    }
}

extension Wallet: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keystore = try container.decode(Keystore.self, forKey: .keystore)
        self.address = try container.decode(Address.self, forKey: .address)
    }
}


//public extension Wallet {
//
////    init(keyPair: KeyPair, network: Network) {
////        self.init(keyPair: keyPair, address:  Address(keyPair: keyPair, network: network))
////    }
//
//    init?(privateKeyHex: String, network: Network = .default) {
//        guard let keyPair = KeyPair(privateKeyHex: privateKeyHex) else { return nil }
//        self.init(keyPair: keyPair, network: network)
//    }
//}
//
//extension Wallet: CustomStringConvertible {}
//public extension Wallet {
//    var description: String {
//        return """
//            address: '\(address)'
//            publicKey: '\(keyPair.publicKey)'
//        """
//    }
//}
