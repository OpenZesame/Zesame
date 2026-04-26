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

extension String {
    /// Splits the string into consecutive substrings of `length` characters.
    ///
    /// - Parameter length: The fixed chunk length. The receiver's `count` must be evenly divisible
    ///   by `length`; otherwise this traps.
    /// - Returns: The chunks in order, as `String` values.
    func splittingIntoSubStringsOfLength(_ length: Int) -> [String] {
        guard count % length == 0 else { fatalError("bad length") }
        var cursor = startIndex
        var results = [Substring]()

        while cursor < endIndex {
            let sliceEnd = index(cursor, offsetBy: length, limitedBy: endIndex) ?? endIndex
            results.append(self[cursor ..< sliceEnd])
            cursor = sliceEnd
        }

        return results.map { String($0) }
    }
}

// MARK: - From String

public extension BigUInt {
    /// Parses a textual integer, auto-detecting hexadecimal (`"0x"`-prefixed) versus decimal input.
    ///
    /// - Parameter string: A decimal string, or a hex string with a leading `"0x"`.
    /// - Returns: `nil` if the string is not a valid integer in the inferred radix.
    init?(string: String) {
        if string.starts(with: "0x") {
            self.init(String(string.dropFirst(2)), radix: 16)
        } else {
            self.init(string, radix: 10)
        }
    }
}
