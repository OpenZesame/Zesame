//
// MIT License
//
// Copyright (c) 2018-2026 Open Zesame (https://github.com/OpenZesame)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

/// Either form of a Zilliqa address. Equality compares the canonical legacy form so a Bech32
/// `Address` and a `LegacyAddress` for the same account compare equal.
public enum Address:
    AddressChecksummedConvertible,
    StringConvertible,
    Hashable,
    ExpressibleByStringLiteral
{
    /// Checksummed legacy hex address.
    case legacy(LegacyAddress)
    /// Bech32 address (`zil1…` / `tzil1…`).
    case bech32(Bech32Address)
}

public extension Address {
    /// Tries Bech32 first, then falls back to legacy hex parsing. The fallback only triggers when
    /// the input is *also* well-formed hex, so unrelated garbage surfaces the original
    /// Bech32 error.
    init(string: String) throws {
        do {
            self = try .bech32(Bech32Address(bech32String: string))
        } catch let bech32Error as Bech32.DecodingError {
            let hexString: HexString
            do {
                hexString = try HexString(string)
            } catch {
                throw Address.Error.invalidBech32Address(bechError: bech32Error)
            }
            self = try .legacy(LegacyAddress(hexString: hexString))
        } catch {
            fatalError(
                "Incorrect implementation, expected error of type Bech32.DecodingError, but got: \(error) of type: \(type(of: error))"
            )
        }
    }
}

// MARK: - AddressChecksummedConvertible

public extension Address {
    /// Reduces either case to its canonical legacy hex form.
    func toChecksummedLegacyAddress() throws -> LegacyAddress {
        switch self {
        case let .bech32(bech32): try bech32.toChecksummedLegacyAddress()
        case let .legacy(legacy): try legacy.toChecksummedLegacyAddress()
        }
    }
}

// MARK: - StringConvertible

public extension Address {
    /// Renders in whichever form the address was constructed in (legacy hex or bech32).
    var asString: String {
        switch self {
        case let .bech32(bech32): bech32.asString
        case let .legacy(legacy): legacy.asString
        }
    }
}

public extension Address {
    /// Equality on the canonical legacy form. Treats a malformed reduction as inequality.
    static func == (
        lhs: Address,
        rhs: Address
    ) -> Bool {
        do {
            return try lhs.toChecksummedLegacyAddress() == rhs.toChecksummedLegacyAddress()
        } catch {
            return false
        }
    }
}
