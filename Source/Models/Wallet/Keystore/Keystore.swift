//
//  Keystore.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-09-23.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import EllipticCurveKit
import CryptoSwift

/// JSON Keys matching those used by Zilliqa JavaScript library: https://github.com/Zilliqa/Zilliqa-Wallet/blob/master/src/app/zilliqa.service.ts
public struct Keystore {

    public let address: String
    public let crypto: Crypto
    public let id: String
    public let version: Int
}

extension Keystore {
    public struct Crypto {
        let cipher: Cipher

        /// "kdf"
        let keyDerivationFunction: KeyDerivationFunction

        /// "mac"
        let messageAuthenticationCode: String
    }
}

extension Keystore.Crypto {
    public struct Cipher {

        public let type: String = "aes-128-ctr"
        public let parameters: Parameters
        public let cipherText: String

        init(parameters: Parameters, cipherText: String) {
            self.parameters = parameters
            self.cipherText = cipherText
        }
    }

    /// KDF
    public struct KeyDerivationFunction {
        public let name: String = "scrypt"
        public let parameters: Scrypt.Input
    }
}

extension Keystore.Crypto.Cipher {
    public struct Parameters {
        /// "iv", as hex string from Data
        public let initializationVectorHexString: String
    }
}

public extension Keystore {
    public init(address: Address, crypto: Crypto, id: String? = nil, version: Int = 3) {
        self.address = address.address
        self.crypto = crypto
        self.id = id ?? UUID().uuidString
        self.version = version
    }
}

extension Keystore.Crypto: Codable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case messageAuthenticationCode = "mac"
        case keyDerivationFunction = "kdf"
        case cipher
    }
}

// MARK: Initialization
public extension Keystore.Crypto {

    /// Convenience
    init(derivedKey: DerivedKey, wallet: Wallet) {
        /// "iv"
        let initializationVector: DataConvertible = try! securelyGenerateBytes(count: 32)

        let aesCtr = try! AES(key: derivedKey.asData.prefix(16).bytes, blockMode: CTR(iv: initializationVector.bytes))

        let encryptedPrivateKey = try! aesCtr.encrypt(wallet.keyPair.privateKey.bytes)

        let mac = (derivedKey.asData.suffix(16) + encryptedPrivateKey).asData.sha3(.sha256)

        self.init(
            cipher: Keystore.Crypto.Cipher(
                parameters:
                Keystore.Crypto.Cipher.Parameters(initializationVectorHexString: initializationVector.asHex),
                cipherText: encryptedPrivateKey.asHex),
            keyDerivationFunction:
            Keystore.Crypto.KeyDerivationFunction(parameters: derivedKey.from),
            messageAuthenticationCode: mac.asHex)
    }
}


extension Keystore.Crypto.Cipher: Codable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case type = "cipher"
        case parameters = "cipherparams"
        case cipherText = "ciphertext"
    }
}

extension Keystore.Crypto.Cipher.Parameters: Codable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case initializationVectorHexString = "iv"
    }
}

extension Keystore.Crypto.KeyDerivationFunction: Codable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case name = "kdf"
        case parameters = "kdfparams"
    }
}


extension Keystore: Codable, Equatable {}


public extension Keystore {
    func toJson() -> [String: Any] {
        return try! asDictionary()
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
