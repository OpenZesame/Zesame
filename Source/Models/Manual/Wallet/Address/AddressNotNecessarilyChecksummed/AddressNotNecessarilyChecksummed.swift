//
//  AddressNotNecessarilyChecksummed.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-12.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation

public struct AddressNotNecessarilyChecksummed: AddressChecksummedConvertible {

    public let hexString: HexString

    // AddressChecksummedConvertible init
    public init(hexString: HexStringConvertible) throws {
        try AddressNotNecessarilyChecksummed.validate(hexString: hexString)
        self.hexString = hexString.hexString
    }
}

public extension AddressNotNecessarilyChecksummed {
    public init(string: String) throws {
        do {
            let hexString = try HexString(string)
            try self.init(hexString: hexString)
        } catch {
            fatalError("Unexpected error:\(error)")
        }
    }

    public static let lengthOfValidAddresses: Int = 40
    static func validate(hexString: HexStringConvertible) throws {
        let length = hexString.length
        if length < lengthOfValidAddresses {
            throw Address.Error.tooShort
        }
        if length > lengthOfValidAddresses {
            throw Address.Error.tooLong
        }
        // is valid
    }
}

// MARK: - AddressChecksummedConvertible
public extension AddressNotNecessarilyChecksummed {
    var checksummedAddress: AddressChecksummed {
        let checksummedHexString = AddressChecksummed.checksummedHexstringFrom(hexString: hexString)
        do {
            return try AddressChecksummed(hexString: checksummedHexString)
        } catch {
            fatalError("Should be able to checksum address, unexpected error: \(error)")
        }
    }
}

extension AddressNotNecessarilyChecksummed: Equatable {}

extension AddressNotNecessarilyChecksummed: ExpressibleByStringLiteral {}
public extension AddressNotNecessarilyChecksummed {
    init(stringLiteral value: String) {
        do {
            try self.init(string: value)
        } catch {
            fatalError("Error: \(error)")
        }
    }
}
