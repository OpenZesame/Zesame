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

/// Marker protocol for amount types that accept *any* value. ``Zil``, ``Li``, ``Qa`` are unbound
/// since they're meant for free-form arithmetic; ``Amount`` is bound because it must respect
/// total supply.
public protocol Unbound: NoLowerbound & NoUpperbound {
    /// Underlying numeric magnitude.
    associatedtype Magnitude: Comparable & Numeric

    /// "Designated" init: stores the raw Qa magnitude unchanged.
    init(qa: Magnitude)

    /// Most important "convenience" init: interprets `value` in the type's natural unit.
    init(_ value: Magnitude)

    /// Convenience init from a `Double` interpreted in the type's natural unit.
    init(_ doubleValue: Double)

    /// Convenience init from an `Int` interpreted in the type's natural unit.
    init(_ intValue: Int)

    /// Reinterprets another amount's Qa magnitude in this type's unit.
    init(_ other: some ExpressibleByAmount)
    /// Reinterprets a ``Zil`` value as `Self`.
    init(zil: Zil)
    /// Reinterprets a ``Li`` value as `Self`.
    init(li: Li)
    /// Reinterprets a ``Qa`` value as `Self`.
    init(qa: Qa)
}
