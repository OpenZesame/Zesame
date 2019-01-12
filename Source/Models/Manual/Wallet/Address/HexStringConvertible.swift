//
//  HexStringConvertible.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-12.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation

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

public extension HexStringConvertible {
    var length: Int {
        return hexString.length
    }

    var isValidAddressButNotNecessarilyChecksummed: Bool {
        do {
            try AddressNotNecessarilyChecksummed.validate(hexString: self)
            // passed validation
            return true
        } catch {
            return false
        }
    }
}

// We dont want to mark `AddressConvertible` as `Equatable` since that puts "`Self` requirements" on it.
public func == (lhs: HexStringConvertible, rhs: HexStringConvertible) -> Bool {
    return lhs.asString == rhs.asString
}
