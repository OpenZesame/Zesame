//
//  AddressNotChecksummed.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-12.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation

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
