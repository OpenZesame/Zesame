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

// MARK: - Validation

public extension Address {
    /// Which address-encoding family a length check is being applied against.
    enum Style: Equatable {
        /// Bech32 form (`zil1…`).
        case bech32
        /// Legacy hex form (`F510…`).
        case ethereum

        /// Expected character count for this style.
        var expectedLength: Int {
            switch self {
            case .bech32: 32 // excluding prefix, delimiter and checksum
            case .ethereum: 40
            }
        }
    }

    /// Reasons a string can fail to parse as an ``Address``.
    enum Error: Swift.Error, Equatable {
        /// Wrong character count for the given encoding style.
        case incorrectLength(expectedLength: Int, forStyle: Style, butGot: Int)
        /// Bech32 data part contained no payload bytes.
        case bech32DataEmpty
        /// Input contained non-hex characters.
        case notHexadecimal
        /// Input wasn't recognised as Bech32 — wraps the underlying decoder error.
        case invalidBech32Address(bechError: Bech32.DecodingError)
        /// Hex shape is correct but the case-folding doesn't match Zilliqa's checksum.
        case notChecksummed
    }
}
