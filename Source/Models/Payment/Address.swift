//
//  Address.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import EllipticCurve
import CryptoSwift

public extension BigUInt {
    func exportToUInt8Array() -> [UInt8] {
        fatalError()
    }
}

/// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
/// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
/// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
/// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
func publicKeyHashToAddress(_ hash: Data) -> String {
    let checksum = Crypto.sha256_sha256(hash).prefix(4)
    let address = Base58.encode(hash + checksum)
    return address
}

public struct Address {

    public enum Network {
        case testnet
        case mainnet

        public var publicKeyHash: UInt8 {
            switch self {
            case .mainnet: return 0
            case .testnet: return 0x6f // = 111 dec
            }
        }
    }

    public static var length: Int { return 40 }
    public static var biggest: Double = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFp0

    public let address: String

    public init(publicKey: PublicKey, network: Network = .testnet) {
        let hash = uint8ArrayToData([network.publicKeyHash]) + Crypto.sha256_ripemd160(uint8ArrayToData(publicKey.publicKey))
        self.address = publicKeyHashToAddress(hash)
    }

    public enum Error: Int, Swift.Error, Equatable {
        case negative
        case tooBig
        case containsDecimals
        case stringNotHex
    }
}
/**
// MARK: - ExpressibleByFloatLiteral
extension Address: ExpressibleByFloatLiteral {}
public extension Address {
    /// This `ExpressibleByFloatLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(floatLiteral value: Double) {
        do {
            self = try Address(double: value)
        } catch {
            fatalError("The value used to create address was invalid, error: \(error)")
        }
    }
}

// MARK: - ExpressibleByStringLiteral
extension Address: ExpressibleByStringLiteral {}
public extension Address {
    /// This `ExpressibleByStringLiteral` init can result in runtime crash if passed invalid values (since the protocol requires the initializer to be non failable, but the designated initializer is).
    public init(stringLiteral value: String) {
        do {
            self = try Address(string: value)
        } catch {
            fatalError("The value used to create address was invalid, error: \(error)")
        }
    }
}

public extension Address {
    init(string: String) throws {
        guard let double = Double(string) else {
            throw Error.stringNotHex
        }
        do {
            self = try Address(double: double)
        } catch {
            fatalError("The string used to create address was invalid, error: \(error)")
        }
    }
}
*/
