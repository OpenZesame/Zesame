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
import Foundation

public extension Data {
    /// Initialize `Data` from a hexadecimal string.
    ///
    /// Accepts an optional `0x` prefix. Odd-length strings are left-padded with a leading `0`
    /// (`"f"` → `0x0f`). Traps on non-hex characters — previously malformed input was silently
    /// truncated, which is hazardous for cryptographic material. Callers that handle untrusted
    /// input should pre-validate via ``init(validatingHex:)``.
    init(hex: String) {
        guard let data = Data(validatingHex: hex) else {
            preconditionFailure("Invalid hex string: \(hex)")
        }
        self = data
    }

    /// Failable counterpart to ``init(hex:)`` that accepts untrusted input.
    ///
    /// Behaves identically (optional `0x` prefix, odd-length left-padding) but returns `nil` on
    /// any non-hex character instead of trapping.
    init?(validatingHex hex: String) {
        var s = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        if !s.count.isMultiple(of: 2) {
            s = "0" + s
        }
        var result = Data()
        result.reserveCapacity(s.count / 2)
        var index = s.startIndex
        while index < s.endIndex {
            let end = s.index(index, offsetBy: 2)
            guard let byte = UInt8(s[index ..< end], radix: 16) else { return nil }
            result.append(byte)
            index = end
        }
        self = result
    }

    /// Convenience static form of ``init(hex:)`` for fluent call sites; traps on invalid input.
    static func fromHexString(_ string: String) -> Data {
        Data(hex: string)
    }

    /// The bytes as a lowercase hexadecimal string (no `0x` prefix).
    var asHex: String {
        map { String(format: "%02x", $0) }.joined()
    }

    /// Interprets the bytes as a big-endian arbitrary-precision unsigned integer.
    var asNumber: BigUInt {
        BigUInt(self)
    }
}
