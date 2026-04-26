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

extension Double {
    /// The decimal-formatted form of the value with trailing zeros (and a hanging decimal
    /// separator) trimmed off — used to render `Double`-derived amount strings cleanly.
    var asStringWithoutTrailingZeros: String {
        var formatted = String(describing: NSNumber(value: self).decimalValue)
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        guard formatted.contains(decimalSeparator) else {
            return formatted
        }
        while formatted.last == "0" {
            formatted = String(formatted.dropLast())
        }

        if String(formatted.last!) == decimalSeparator {
            formatted = String(formatted.dropLast())
        }

        return formatted
    }
}

public extension ExpressibleByAmount {
    /// Debug-friendly form: Qa magnitude alongside the value in Zil.
    var debugDescription: String {
        "\(qa) qa (\(asString(in: .zil, roundingIfNeeded: nil)) Zils)"
    }

    /// The value rendered in Zil.
    var zilString: String {
        asString(in: .zil)
    }

    /// The value rendered in Li.
    var liString: String {
        asString(in: .li)
    }

    /// The value rendered in Qa (no decimal places — Qa is the base unit).
    var qaString: String {
        String(qa)
    }

    /// Renders the amount as a localised string in `targetUnit`.
    ///
    /// - Parameters:
    ///   - targetUnit: The unit to render in.
    ///   - roundingIfNeeded: Optional rounding mode applied only when rendering in the same unit
    ///     this value was constructed in.
    ///   - roundingNumberOfDigits: Number of digits to round to when `roundingIfNeeded` is set.
    ///   - minFractionDigits: Minimum digits after the decimal separator (e.g. for `1.50`).
    func asString(
        in targetUnit: Unit,
        roundingIfNeeded: NSDecimalNumber.RoundingMode? = nil,
        roundingNumberOfDigits: Int = 2,
        minFractionDigits: Int? = nil
    ) -> String {
        // handle trivial edge case
        if targetUnit == .qa {
            return "\(qa)"
        }

        let decimal = decimalValue(
            in: targetUnit,
            rounding: roundingIfNeeded,
            roundingNumberOfDigits: roundingNumberOfDigits
        )
        let nsDecimalNumber = NSDecimalNumber(decimal: decimal)
        guard let decimalString = asStringUsingLocalizedDecimalSeparator(
            nsDecimalNumber: nsDecimalNumber,
            maxFractionDigits: 12,
            minFractionDigits: minFractionDigits
        ) else {
            fatalError("should be able to create string")
        }
        return decimalString
    }
}
