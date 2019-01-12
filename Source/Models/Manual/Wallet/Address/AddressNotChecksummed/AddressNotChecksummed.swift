//
//  Address.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2018-10-05.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import CryptoSwift
import EllipticCurveKit

public protocol HexStringConvertible {
    var hexString: HexString { get }
}

public extension HexStringConvertible {
    var asString: String {
        return hexString.value
    }
}

extension HexString: HexStringConvertible {}
public extension HexString {
    var hexString: HexString { return self }
}

extension String: HexStringConvertible {
    public var hexString: HexString {
        do {
            return try HexString(self)
        } catch {
            fatalError("String: `\(self)` is not valid HexString, error: \(error)")
        }
    }
}

// We dont want to mark `AddressConvertible` as `Equatable` since that puts "`Self` requirements" on it.
public func == (lhs: HexStringConvertible, rhs: HexStringConvertible) -> Bool {
    return lhs.asString == rhs.asString
}


public extension HexStringConvertible {
    var length: Int {
        return hexString.length
    }

    var isValidAddressButNotNecessarilyChecksummed: Bool {
        do {
            try AddressNotChecksummed.validate(hexString: self)
            // passed validation
            return true
        } catch {
            return false
        }
    }
}

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

public enum Address {
    case checksummed(AddressChecksummed)
    case notNecessarilyChecksummed(AddressNotChecksummed)
}

public extension Address {
    init(hexString: HexStringConvertible) throws {
        if AddressChecksummed.isChecksummed(hexString: hexString) {
            do {
                self = .checksummed(try AddressChecksummed(hexString: hexString))
            } catch {
                fatalError("Hexstring was checksummed: `\(hexString)`, unexpexted error: `\(error)`")
            }
        } else {
            self = .notNecessarilyChecksummed(try AddressNotChecksummed(hexString: hexString))
        }
    }
}

extension Address: AddressChecksummedConvertible {}
public extension Address {
    var checksummedAddress: AddressChecksummed {
        switch self {
        case .checksummed(let checksummed): return checksummed
        case .notNecessarilyChecksummed(let notNecessarilyChecksummed): return notNecessarilyChecksummed.checksummedAddress
        }
    }
}


public struct AddressChecksummed {
    public enum Error: Swift.Error {
        case notChecksummed
    }
    public let checksummed: HexString
    public init(hexString: HexStringConvertible) throws {
        guard AddressChecksummed.isChecksummed(hexString: hexString) else {
            throw Error.notChecksummed
        }
        self.checksummed = hexString.hexString
    }

    static func isChecksummed(hexString: HexStringConvertible) -> Bool {
        guard
            hexString.isValidAddressButNotNecessarilyChecksummed,
            case let checksummed = checksummedHexstringFrom(hexString: hexString),
            checksummed == hexString
            else { return false }
        return true
    }


    // Checksums a Zilliqa address, implementation is based on Javascript library:
    // https://github.com/Zilliqa/Zilliqa-JavaScript-Library/blob/9368fb34a0d443797adc1ecbcb9728db9ce75e97/packages/zilliqa-js-crypto/src/util.ts#L76-L96
    static func checksummedHexstringFrom(hexString: HexStringConvertible) -> HexString {
        let string = hexString.asString
        let numberFromHash = EllipticCurveKit.Crypto.hash(Data(hex: string), function: HashFunction.sha256).asNumber
        var checksummedString: String = ""
        for (i, character) in string.enumerated() {
            let string = String(character)
            let characterIsLetter = CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: string))
            guard characterIsLetter else {
                checksummedString += string
                continue
            }
            let andOperand: Number = Number(2).power(255 - 6 * i)
            let shouldUppercase = (numberFromHash & andOperand) >= 1
            checksummedString += shouldUppercase ? string.uppercased() : string.lowercased()
        }

        do {
            return try HexString(checksummedString)
        } catch {
            fatalError("Should be hexstring, unexpected error: \(error)")
        }
    }
}

extension AddressChecksummed: AddressChecksummedConvertible {}
public extension AddressChecksummed {
    var checksummedAddress: AddressChecksummed { return self }
}

extension AddressChecksummed: Equatable {}

public struct AddressNotChecksummed {
    public let hexString: HexString
    public init(hexString: HexStringConvertible) throws {
        try AddressNotChecksummed.validate(hexString: hexString)
        self.hexString = hexString.hexString
    }

    public init(string: String) throws {
        do {
            let hexString = try HexString(string)
            try self.init(hexString: hexString)
        } catch let error as HexString.Error {
            switch error {
            case .notHexadecimal: throw Error.notHexadecimal
            }
        } catch {
            fatalError("Unexpected error:\(error)")
        }
    }

    public enum Error: Swift.Error {
        case tooLong
        case tooShort
        case notHexadecimal
    }

    public static let lengthOfValidAddresses: Int = 40
    static func validate(hexString: HexStringConvertible) throws {
        let length = hexString.length
        if length < lengthOfValidAddresses {
            throw Error.tooShort
        }
        if length > lengthOfValidAddresses {
            throw Error.tooLong
        }
        // is valid
    }
}

extension AddressNotChecksummed: AddressChecksummedConvertible {}
public extension AddressNotChecksummed {
    var checksummedAddress: AddressChecksummed {
        let checksummedHexString = AddressChecksummed.checksummedHexstringFrom(hexString: hexString)
        do {
            return try AddressChecksummed(hexString: checksummedHexString)
        } catch {
            fatalError("Should be able to checksum address, unexpected error: \(error)")
        }
    }
}

// MARK: - Convenience Initializers


extension AddressNotChecksummed: Equatable {}

extension AddressNotChecksummed: ExpressibleByStringLiteral {}
public extension AddressNotChecksummed {
     init(stringLiteral value: String) {
        do {
            try self.init(string: value)
        } catch {
            fatalError("Error: \(error)")
        }
    }
}
