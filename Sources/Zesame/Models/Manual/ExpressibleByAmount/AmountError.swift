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

/// Validation errors thrown by ``ExpressibleByAmount`` initialisers, parameterised over the
/// concrete amount type so the failing bound is reported in the right unit.
public enum AmountError<E: ExpressibleByAmount>: Swift.Error, Equatable {
    /// The value is below the type's lower bound. Carries the offending bound for diagnostics.
    case tooSmall(min: E)
    /// The value is above the type's upper bound.
    case tooLarge(max: E)
    /// The string parser couldn't extract a number at all.
    case nonNumericString
    /// The string ends with a stray decimal separator (e.g. `"1.2."`).
    case endsWithDecimalSeparator
    /// The string contains a character that's neither a digit nor the decimal separator.
    case containsNonDecimalStringCharacter(disallowedCharacter: String)
    /// More than one `.`/`,` was found.
    case moreThanOneDecimalSeparator
    /// More fractional digits than the unit can represent without losing precision.
    case tooManyDecimalPlaces
}
