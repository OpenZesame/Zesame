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

extension String {
    /// Counts the number of fractional digits after the decimal separator.
    ///
    /// Treats both `.` and `,` as the separator (normalised to the current locale). Returns 0
    /// for strings without a separator. Callers must pre-validate that the input contains at
    /// most one separator (via ``doesNotContainMoreThanOneDecimalSeparator()``); the parse below
    /// returns the count of digits after the *first* separator and ignores anything else.
    func countDecimalPlaces() -> Int {
        guard containsDecimalSeparator() else { return 0 }
        let decimalSeparator = Locale.current.decimalSeparatorForSure
        let normalised = replacingIncorrectDecimalSeparatorIfNeeded()
        guard let fractional = normalised.components(separatedBy: decimalSeparator).dropFirst().first
        else { return 0 }
        return fractional.count
    }

    /// Returns `true` when at most one decimal separator is present (zero or one), regardless of
    /// whether `.` or `,` was used.
    func doesNotContainMoreThanOneDecimalSeparator() -> Bool {
        let decimalSeparator = Locale.current.decimalSeparatorForSure

        guard replacingIncorrectDecimalSeparatorIfNeeded().components(separatedBy: decimalSeparator).count < 3 else {
            return false
        }
        return true
    }

    /// Normalises both `.` and `,` to the current locale's decimal separator so that
    /// downstream parsing is locale-correct.
    func replacingIncorrectDecimalSeparatorIfNeeded() -> String {
        let decimalSeparator = Locale.current.decimalSeparatorForSure

        return replacingOccurrences(of: ".", with: decimalSeparator)
            .replacingOccurrences(of: ",", with: decimalSeparator)
    }
}

/// Formats an `NSDecimalNumber` using the user's locale-specific decimal separator.
///
/// - Parameters:
///   - nsDecimalNumber: The value to format.
///   - maxFractionDigits: Upper bound on fractional digits (extra digits are rounded away).
///   - minFractionDigits: Optional lower bound; when `nil`, the formatter chooses the minimum.
/// - Returns: The formatted string, or `nil` if `NumberFormatter` cannot render the value.
func asStringUsingLocalizedDecimalSeparator(
    nsDecimalNumber: NSDecimalNumber,
    maxFractionDigits: Int,
    minFractionDigits: Int? = nil
) -> String? {
    let formatter = NumberFormatter()
    formatter.decimalSeparator = Locale.current.decimalSeparatorForSure
    formatter.maximumFractionDigits = maxFractionDigits
    formatter.minimumIntegerDigits = 1
    if let minFractionDigits {
        formatter.minimumFractionDigits = minFractionDigits
    }
    return formatter.string(from: nsDecimalNumber)
}

private extension String {
    /// `true` if the string contains the current locale's decimal separator.
    func containsDecimalSeparator() -> Bool {
        contains(Locale.current.decimalSeparatorForSure)
    }
}
