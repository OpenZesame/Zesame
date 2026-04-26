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

import BigInt
import CryptoKit
import Foundation

extension CharacterSet {
    /// `0-9` ∪ `a-f` ∪ `A-F`. The set of valid hexadecimal digits.
    static var hexadecimalDigits: CharacterSet {
        let afToAF = CharacterSet(charactersIn: "abcdefABCDEF")
        return CharacterSet.decimalDigits.union(afToAF)
    }
}

/// A validated hexadecimal string with the leading `0x` prefix stripped.
///
/// The constructor enforces that every character is a hex digit, so values of this type can be
/// trusted downstream. Note that the type does *not* enforce a specific length — that's the job
/// of the consumer (e.g. ``LegacyAddress``).
public struct HexString {
    /// The hex characters, without `0x` prefix.
    public let value: String
    /// Validates that `value` is purely hex (after stripping any `0x` prefix). Throws
    /// ``Address/Error/notHexadecimal`` otherwise.
    init(_ value: String) throws {
        let value = value.droppingLeading0x()
        guard CharacterSet.hexadecimalDigits.isSuperset(of: CharacterSet(charactersIn: value)) else {
            throw Address.Error.notHexadecimal
        }
        self.value = value
    }
}

public extension HexString {
    /// Checksums a Zilliqa address, implementation is based on Javascript library:
    /// https://github.com/Zilliqa/Zilliqa-JavaScript-Library/blob/9368fb34a0d443797adc1ecbcb9728db9ce75e97/packages/zilliqa-js-crypto/src/util.ts#L76-L96
    ///
    /// The casing of each letter is determined by individual bits of the SHA-256 of the lowercase
    /// address, mirroring EIP-55 in spirit but using a different bit selection schedule. Traps
    /// for inputs that aren't valid 20-byte addresses — call sites must pre-validate.
    var checksummed: LegacyAddress {
        let string = value

        var hasher = SHA256()
        hasher.update(data: hexString.asData)
        let hash = hasher.finalize()
        let numberFromHash = BigUInt(Data(hash))

        var checksummedString = ""
        for (i, character) in string.enumerated() {
            let string = String(character)
            let characterIsLetter = CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: string))
            guard characterIsLetter else {
                checksummedString += string
                continue
            }
            let andOperand = BigUInt(2).power(255 - 6 * i)
            let shouldUppercase = (numberFromHash & andOperand) >= 1
            checksummedString += shouldUppercase ? string.uppercased() : string.lowercased()
        }

        guard
            let checksummedHexString = try? HexString(checksummedString),
            let checksummedAddress = try? LegacyAddress(hexString: checksummedHexString)
        else {
            fatalError("Incorrect implementation")
        }
        return checksummedAddress
    }
}

extension HexString: DataConvertible {}
public extension HexString {
    /// The decoded hex bytes.
    var asData: Data {
        Data(hex: value)
    }
}

extension HexString: Codable {
    /// Decodes from a single bare string JSON value.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(container.decode(String.self))
    }
}

extension HexString: Hashable {}
extension HexString: ExpressibleByStringLiteral {}
public extension HexString {
    /// Allows ``HexString`` to be written as a string literal. Traps if the literal isn't valid
    /// hex.
    init(stringLiteral value: String) {
        do {
            try self.init(value)
        } catch {
            fatalError("String value: `\(value)` passed is not a valid hexadecimal string, error: \(error)")
        }
    }
}

// public typealias HexString = String

public extension String {
    /// Strips any number of leading `"0x"` prefixes — handy for normalising user input.
    func droppingLeading0x() -> String {
        var string = self
        while string.starts(with: "0x") {
            string = String(string.dropFirst(2))
        }
        return string
    }

//    var isAddress: Bool {
//        return Address.isValidAddress(hexString: self)
//    }
}

public extension HexString {
    /// Number of hex characters in the value (twice the byte count).
    var length: Int {
        value.count
    }
}

extension HexString: CustomStringConvertible {}
public extension HexString {
    /// `description` is the bare hex string (no `0x` prefix).
    var description: String {
        value
    }
}
