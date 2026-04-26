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

/// Marker protocol for amount types that enforce a value range. Throwing initialisers signal that
/// inputs outside the range surface as ``AmountError`` rather than trapping.
public protocol Bound {
    /// The underlying numeric magnitude (always ``BigInt`` in practice).
    associatedtype Magnitude: Comparable & Numeric

    /// "Designated" init, check bounds.
    init(qa: Magnitude) throws

    /// Most important "convenience" init: interprets `value` in the type's natural unit.
    init(_ value: Magnitude) throws

    /// Convenience init from a `Double` interpreted in the type's natural unit.
    init(_ doubleValue: Double) throws

    /// Convenience init from an `Int` interpreted in the type's natural unit.
    init(_ intValue: Int) throws
}

public extension Bound where Self: AdjustableLowerbound, Self: AdjustableUpperbound {
    /// Resets both the lower and upper bounds to their factory defaults. Useful for tests that
    /// have temporarily adjusted ``GasPrice/minInQa`` etc.
    static func restoreDefaultBounds() {
        restoreDefaultMin()
        restoreDefaultMax()
    }
}
