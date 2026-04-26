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

/// Zilliqa native-currency units. The raw value is the exponent (relative to Zil) — Zil is `0`,
/// Li is `-6` (10⁻⁶ Zil), Qa is `-12` (10⁻¹² Zil = the smallest indivisible unit).
public enum Unit: Int {
    /// Zilliqa's display unit (1 Zil = 10⁶ Li = 10¹² Qa).
    case zil = 0
    /// Mid-tier unit, 10⁻⁶ Zil.
    case li = -6
    /// The base atomic unit, 10⁻¹² Zil.
    case qa = -12
}

public extension Unit {
    /// Power-of-ten exponent relative to Zil.
    var exponent: Int {
        rawValue
    }

    /// Diagnostic rendering of the exponent (`"10^-6"`, `"10^-12"`, `"10^0"`).
    var powerOf: String {
        "10^\(exponent)"
    }

    /// Lowercase short name (`"zil"`, `"li"`, `"qa"`).
    var name: String {
        switch self {
        case .zil: "zil"
        case .li: "li"
        case .qa: "qa"
        }
    }
}

extension Unit: CustomStringConvertible {
    /// `Unit`s render as their ``name``.
    public var description: String {
        name
    }
}
