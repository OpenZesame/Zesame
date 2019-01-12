//
//  Address.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-12.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation

public enum Address {
    case checksummed(AddressChecksummed)
    case notNecessarilyChecksummed(AddressNotNecessarilyChecksummed)
}

// MARK: - Validation
public extension Address {
    public enum Error: Swift.Error {
        case tooLong
        case tooShort
        case notHexadecimal
        case notChecksummed
    }
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
            self = .notNecessarilyChecksummed(try AddressNotNecessarilyChecksummed(hexString: hexString))
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
