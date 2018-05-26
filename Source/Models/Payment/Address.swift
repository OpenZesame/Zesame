//
//  Address.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Address {
    public static var length: Int { return 40 }
    public static var biggest: Double = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFp0

    public let address: Double

    public init(double: Double) throws {
        self.address = double
    }

    public enum Error: Int, Swift.Error, Equatable {
        case negative
        case tooBig
        case containsDecimals
        case stringNotHex
    }
}

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
