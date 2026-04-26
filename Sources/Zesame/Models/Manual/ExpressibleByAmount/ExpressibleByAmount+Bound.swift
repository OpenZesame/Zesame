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

public extension ExpressibleByAmount where Self: Bound {
    /// Most important "convenience" init
    init(_ value: Magnitude) throws {
        try self.init(qa: Self.toQa(magnitude: value))
    }

    /// Bypasses error handling for inputs that are statically known to validate. Traps on
    /// out-of-bounds input — only use for compile-time-known constants.
    init(valid: Magnitude) {
        do {
            try self.init(valid)
        } catch {
            fatalError("The value `valid` (`\(valid)`) passed was invalid, error: \(error)")
        }
    }
}

public extension ExpressibleByAmount where Self: Bound {
    /// Constructs from a `Double` interpreted in this type's unit.
    init(_ doubleValue: Double) throws {
        try self.init(qa: Self.toQa(double: doubleValue))
    }

    /// Constructs from an `Int` interpreted in this type's unit.
    init(_ intValue: Int) throws {
        try self.init(Magnitude(intValue))
    }

    /// Parses `untrimmed` as an amount in this type's unit, applying bound validation.
    init(
        trimming untrimmed: String
    ) throws {
        let trimmed = try Self.trimmingAndFixingDecimalSeparator(in: untrimmed)

        if let value = Magnitude(trimmed) {
            try self.init(Self.validate(value: value))
        } else if let double = Double.fromString(trimmed) {
            try self.init(double)
        } else {
            throw AmountError<Self>.nonNumericString
        }
    }
}

public extension Double {
    /// Locale-tolerant `Double` parsing.
    ///
    /// Tries the C-locale `Double(_:)` first; on failure, falls back to walking every available
    /// `Locale` until one accepts the string. Slow but bullet-proof for user input that may use
    /// a foreign decimal separator.
    static func fromString(_ string: String) -> Double? {
        func doubleFromAnyLocaleOfTheAvailableLocales(numberString: String) -> Double? {
            func doubleFromStringUsingLocale(_ locale: Locale) -> Double? {
                let formatter = NumberFormatter()
                formatter.locale = locale
                return formatter.number(from: numberString)?.doubleValue
            }

            for localeIdentifier in Locale.availableIdentifiers {
                let locale = Locale(identifier: localeIdentifier)
                if let double = doubleFromStringUsingLocale(locale) {
                    return double
                }
            }
            return nil
        }
        if let doubleWithoutFormatter = Double(string) {
            return doubleWithoutFormatter
        } else {
            return doubleFromAnyLocaleOfTheAvailableLocales(numberString: string)
        }
    }
}

public extension ExpressibleByAmount where Self: Bound {
    /// Reinterprets another amount in this type's unit, validated against `Self`'s bounds.
    init(_ other: some ExpressibleByAmount) throws {
        try self.init(qa: other.qa)
    }

    /// Validated reinterpretation of a Zil amount.
    init(zil: Zil) throws {
        try self.init(zil)
    }

    /// Validated reinterpretation of a Li amount.
    init(li: Li) throws {
        try self.init(li)
    }

    /// Validated reinterpretation of a Qa amount.
    init(qa: Qa) throws {
        try self.init(qa)
    }
}

public extension ExpressibleByAmount where Self: Bound {
    /// Parses a Zil-denominated string with bounds-validation.
    init(zil zilString: String) throws {
        try self.init(zil: Zil(trimming: zilString))
    }

    /// Parses a Li-denominated string with bounds-validation.
    init(li liString: String) throws {
        try self.init(li: Li(trimming: liString))
    }

    /// Parses a Qa-denominated string with bounds-validation.
    init(qa qaString: String) throws {
        try self.init(qa: Qa(trimming: qaString))
    }
}

// MARK: - ExpressibleByFloatLiteral

public extension ExpressibleByAmount where Self: Bound {
    /// Float literal; traps on out-of-bounds values.
    init(floatLiteral double: Double) {
        do {
            try self.init(double)
        } catch {
            fatalError("The `Double` value (`\(double)`) passed was invalid, error: \(error)")
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral

public extension ExpressibleByAmount where Self: Bound {
    /// Integer literal; traps on out-of-bounds values.
    init(integerLiteral int: Int) {
        do {
            try self.init(int)
        } catch {
            fatalError("The `Int` value (`\(int)`) passed was invalid, error: \(error)")
        }
    }
}

// MARK: - ExpressibleByStringLiteral

public extension ExpressibleByAmount where Self: Bound {
    /// String literal; traps on parse or out-of-bounds errors.
    init(stringLiteral string: String) {
        do {
            try self = Self(trimming: string)
        } catch {
            fatalError("The `String` value (`\(string)`) passed was invalid, error: \(error)")
        }
    }
}
