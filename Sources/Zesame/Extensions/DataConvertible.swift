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

/// A type that has a canonical byte representation.
///
/// Conformers expose their value as `Data`, which gives a free `asHex` projection. Cryptographic
/// primitives in this library (addresses) conform so they can be used uniformly wherever a byte
/// sequence is required.
public protocol DataConvertible {
    /// The canonical byte representation of the value.
    var asData: Data { get }
}

public extension DataConvertible {
    /// The value as a lowercase hexadecimal string (no `0x` prefix).
    var asHex: String {
        asData.asHex
    }
}

public extension [UInt8] {
    /// The bytes wrapped in a `Data` value. Used at sites that pipe `[UInt8]` results
    /// (e.g. `Bech32.convertbits`) into `Data`-typed APIs.
    var asData: Data {
        Data(self)
    }
}
