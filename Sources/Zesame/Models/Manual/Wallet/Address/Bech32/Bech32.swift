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

// Found: https://github.com/0xDEADP00L/Bech32/blob/master/Sources/Bech32.swift

/// Bech32 checksum implementation. Used as a namespace; the type itself is uninstantiable.
public enum Bech32 {}

public extension Bech32 {
    /// Encodes raw 5-bit-grouped bytes as their Bech32 character form.
    static func dataToString(data: Data) -> String {
        var ret = Data()
        for i in data {
            ret.append(charsetForEncoding[Int(i)])
        }
        // The mapped bytes are always ASCII (Bech32 alphabet), so UTF-8 decoding cannot fail.
        guard let s = String(data: ret, encoding: .utf8) else {
            preconditionFailure("Bech32 alphabet bytes failed UTF-8 decode — impossible by construction")
        }
        return s
    }

    /// Decodes a string string into a `Bech32Address`
    static func decode(_ str: String) throws -> Bech32Address {
        guard let strBytes = str.data(using: .utf8) else {
            throw DecodingError.nonUTF8String
        }
        guard strBytes.count <= 90 else {
            throw DecodingError.stringLengthExceeded
        }
        var lower = false
        var upper = false
        for c in strBytes {
            // printable range
            if c < 33 || c > 126 {
                throw DecodingError.nonPrintableCharacter
            }
            // 'a' to 'z'
            if c >= 97, c <= 122 {
                lower = true
            }
            // 'A' to 'Z'
            if c >= 65, c <= 90 {
                upper = true
            }
        }
        if lower, upper {
            throw DecodingError.invalidCase
        }
        guard let pos = str.range(of: checksumMarker, options: .backwards)?.lowerBound else {
            throw DecodingError.noChecksumMarker
        }
        let intPos: Int = str.distance(from: str.startIndex, to: pos)
        guard intPos >= 1 else {
            throw DecodingError.incorrectHumanReadablePartSize
        }
        guard intPos + 7 <= str.count else {
            throw DecodingError.incorrectChecksumSize
        }
        let vSize: Int = str.count - 1 - intPos
        var values = Data(repeating: 0x00, count: vSize)
        for i in 0 ..< vSize {
            let c = strBytes[i + intPos + 1]
            let decInt = charsetForDecoding[Int(c)]
            if decInt == -1 {
                throw DecodingError.invalidCharacter
            }
            values[i] = UInt8(decInt)
        }
        let humanReadablePrefix = String(str[..<pos]).lowercased()
        guard verifyChecksum(humanReadablePart: humanReadablePrefix, checksum: values) else {
            throw DecodingError.checksumMismatch
        }

        let checksumLength = 6
        let humanReadableRelevantData = values.prefix(upTo: values.count - checksumLength)
        let checksumData = values.suffix(checksumLength)

        let dataPart = Bech32Address.DataPart(
            dataExcludingChecksum: humanReadableRelevantData,
            checksum: checksumData
        )

        return Bech32Address(prefix: humanReadablePrefix, dataPart: dataPart)
    }

    /// Create checksum
    ///
    /// Computes the 6-symbol Bech32 checksum for the given HRP + value bytes.
    static func createChecksum(
        humanReadablePart: String,
        values: Data
    ) -> Data {
        var enc = expandHumanReadablePart(humanReadablePart)
        enc.append(values)
        enc.append(Data(repeating: 0x00, count: 6))
        let mod: UInt32 = polymod(enc) ^ 1
        var ret = Data(repeating: 0x00, count: 6)
        for i in 0 ..< 6 {
            ret[i] = UInt8((mod >> (5 * (5 - i))) & 31)
        }
        return ret
    }

    /// Re-groups `data`'s bits from `fromBits` to `toBits` per element. Bech32 needs `8 → 5` for
    /// encoding and `5 → 8` for decoding; `pad` controls whether trailing leftover bits are
    /// padded out to a full chunk.
    static func convertbits(
        data: [UInt8],
        fromBits: Int,
        toBits: Int,
        pad: Bool
    ) throws -> [UInt8] {
        var acc = Int()
        var bits = UInt8()
        let maxv = (1 << toBits) - 1

        let converted: [[Int]] = try data.map { value in
            if value < 0 || UInt8(Int(value) >> fromBits) != 0 {
                throw Bech32.DecodingError.invalidCharacter
            }

            acc = (acc << fromBits) | Int(value)
            bits += UInt8(fromBits)

            var values = [Int]()

            while bits >= UInt8(toBits) {
                bits -= UInt8(toBits)
                values += [(acc >> Int(bits)) & maxv]
            }

            return values
        }

        let padding = pad && bits > UInt8() ? [acc << (toBits - Int(bits)) & maxv] : []

        if !pad, bits >= UInt8(fromBits) || acc << (toBits - Int(bits)) & maxv > Int() {
            throw Bech32.DecodingError.invalidCase
        }

        return ((converted.flatMap(\.self)) + padding).map { UInt8($0) }
    }
}

public extension Bech32 {
    /// Bech32 checksum delimiter
    static let checksumMarker = "1"
    /// Bech32 alphabet (32 characters, in the canonical order specified by BIP-173).
    static let alphabetString = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
}

private extension Bech32 {
    static let generator: [UInt32] = [0x3B6A_57B2, 0x2650_8E6D, 0x1EA1_19FA, 0x3D42_33DD, 0x2A14_62B3]

    // Bech32 character set for encoding

    static let charsetForEncoding: Data = alphabetString.data(using: .utf8)!

    /// Bech32 character set for decoding
    static let charsetForDecoding: [Int8] = [
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        15, -1, 10, 17, 21, 20, 26, 30, 7, 5, -1, -1, -1, -1, -1, -1,
        -1, 29, -1, 24, 13, 25, 9, 8, 23, -1, 18, 22, 31, 27, 19, -1,
        1, 0, 3, 16, 11, 28, 12, 14, 6, 4, 2, -1, -1, -1, -1, -1,
        -1, 29, -1, 24, 13, 25, 9, 8, 23, -1, 18, 22, 31, 27, 19, -1,
        1, 0, 3, 16, 11, 28, 12, 14, 6, 4, 2, -1, -1, -1, -1, -1,
    ]
}

private extension Bech32 {
    /// Find the polynomial with value coefficients mod the generator as 30-bit.
    static func polymod(_ values: Data) -> UInt32 {
        var chk: UInt32 = 1
        for v in values {
            let top = (chk >> 25)
            chk = (chk & 0x1FFFFFF) << 5 ^ UInt32(v)
            for i: UInt8 in 0 ..< 5 {
                chk ^= ((top >> i) & 1) == 0 ? 0 : generator[Int(i)]
            }
        }
        return chk
    }

    /// Expand a HRP for use in checksum computation.
    static func expandHumanReadablePart(_ humanReadablePart: String) -> Data {
        guard let humanReadablePartBytes = humanReadablePart.data(using: .utf8) else { return Data() }
        var result = Data(repeating: 0x00, count: humanReadablePartBytes.count * 2 + 1)
        for (i, c) in humanReadablePartBytes.enumerated() {
            result[i] = c >> 5
            result[i + humanReadablePartBytes.count + 1] = c & 0x1F
        }
        result[humanReadablePart.count] = 0
        return result
    }

    /// Verify checksum
    static func verifyChecksum(
        humanReadablePart: String,
        checksum: Data
    ) -> Bool {
        var data = expandHumanReadablePart(humanReadablePart)
        data.append(checksum)
        return polymod(data) == 1
    }
}

public extension Bech32 {
    /// Failures that can be reported by ``Bech32/decode(_:)``. Cases are grouped roughly by
    /// "shape" failures (length/charset/case) versus "checksum failed".
    enum DecodingError: LocalizedError {
        /// The input bytes are not valid UTF-8.
        case nonUTF8String
        /// One of the bytes lies outside the printable ASCII range.
        case nonPrintableCharacter
        /// The string mixes upper and lower case (Bech32 forbids this).
        case invalidCase
        /// The checksum delimiter (`1`) was not found.
        case noChecksumMarker
        /// The human-readable prefix is empty.
        case incorrectHumanReadablePartSize
        /// The checksum portion is shorter than 6 characters.
        case incorrectChecksumSize
        /// The input is longer than the 90-character Bech32 limit.
        case stringLengthExceeded

        /// A character outside the Bech32 alphabet was encountered.
        case invalidCharacter
        /// The checksum failed to verify.
        case checksumMismatch

        /// Human-readable description for `LocalizedError` consumers.
        public var errorDescription: String? {
            switch self {
            case .checksumMismatch:
                "Checksum doesn't match"
            case .incorrectChecksumSize:
                "Checksum size too low"
            case .incorrectHumanReadablePartSize:
                "Human-readable-part is too small or empty"
            case .invalidCase:
                "String contains mixed case characters"
            case .invalidCharacter:
                "Invalid character met on decoding"
            case .noChecksumMarker:
                "Checksum delimiter not found"
            case .nonPrintableCharacter:
                "Non printable character in input string"
            case .nonUTF8String:
                "String cannot be decoded by utf8 decoder"
            case .stringLengthExceeded:
                "Input string is too long"
            }
        }
    }
}
