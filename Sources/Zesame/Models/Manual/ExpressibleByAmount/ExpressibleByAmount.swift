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

/// A type representing an Zilliqa amount in any denominator, specified by the `Unit` and the value measured
/// in said unit by the `Magnitude`. For convenience any type can be converted to the default units, such as
/// Zil, Li, and Qa. Any type can also be initialized from said units. For convenience we can perform arithmetic
/// between two instances of the same type but we can also perform artithmetic between two different types, e.g.
/// Zil(2) + Li(3_000_000) // 5 Zil
/// We can also compare them of course. An extension on The Magnitude allows for syntax like 3.zil
/// analogously for Li and Qa.
public protocol ExpressibleByAmount:
    Codable,
    Comparable,
    CustomDebugStringConvertible,
    ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByStringLiteral
    where Magnitude == BigInt
{
    /// The arbitrary-precision integer used to back the value (always ``BigInt``).
    associatedtype Magnitude

    /// The conforming type's natural unit (Zil, Li, or Qa). Determines how the type renders and
    /// how literals are interpreted.
    static var unit: Unit { get }
    /// Canonical magnitude in Qa, the smallest unit. All arithmetic and comparisons reduce to this.
    var qa: Magnitude { get }

    /// "Designated" initializer.
    ///
    /// Passes through validation — for ``Bound`` conformers this traps on out-of-bounds input,
    /// matching the spelling at literal-construction sites.
    init(valid: Magnitude)

    /// The amount expressed in Li.
    var asLi: Li { get }
    /// The amount expressed in Zil.
    var asZil: Zil { get }
    /// The amount expressed in Qa.
    var asQa: Qa { get }

    /// Validates a raw Qa magnitude against the conforming type's bounds. The default
    /// implementations are provided by the `Bound`/`Unbound` extensions.
    static func validate(value: Magnitude) throws -> Magnitude

    /// Parses an amount string in this type's unit.
    init(trimming: String) throws
    /// Reinterprets another amount in this type's unit.
    init(_ other: some ExpressibleByAmount) throws
    /// Reinterprets a ``Zil`` value as `Self`.
    init(zil: Zil) throws
    /// Reinterprets a ``Li`` value as `Self`.
    init(li: Li) throws
    /// Reinterprets a ``Qa`` value as `Self`.
    init(qa: Qa) throws
    /// Parses a Zil-denominated string and reinterprets the result as `Self`.
    init(zil: String) throws
    /// Parses a Li-denominated string and reinterprets the result as `Self`.
    init(li: String) throws
    /// Parses a Qa-denominated string and reinterprets the result as `Self`.
    init(qa: String) throws
}

public extension ExpressibleByAmount {
    /// Instance-level access to the static ``unit`` requirement.
    var unit: Unit {
        Self.unit
    }

    /// String describing the unit's power of ten relative to Qa (`"10^12"`, `"10^6"`, `"10^0"`).
    static var powerOf: String {
        unit.powerOf
    }
}
