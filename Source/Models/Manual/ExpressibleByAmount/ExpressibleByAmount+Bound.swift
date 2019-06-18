//
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
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
    
    init(valid: Magnitude) {
        do {
            try self.init(valid)
        } catch {
            fatalError("The value `valid` (`\(valid)`) passed was invalid, error: \(error)")
        }
    }
}

public extension ExpressibleByAmount where Self: Bound {
    
    init(_ doubleValue: Double) throws {
        try self.init(qa: Self.toQa(double: doubleValue))
    }
    
    init(_ intValue: Int) throws {
        try self.init(Magnitude(intValue))
    }
    
    init(
        trimming untrimmed: String
    ) throws {
        
        let trimmed = try Self.trimmingAndFixingDecimalSeparator(in: untrimmed)
        
        if let value = Magnitude(decimalString: trimmed) {
            try self.init(try Self.validate(value: value))
        } else if let double = Double.fromString(trimmed) {
            try self.init(double)
        } else {
            throw AmountError<Self>.nonNumericString
        }
    }
}

public extension Double {
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
    init<E>(_ other: E) throws where E: ExpressibleByAmount {
        try self.init(qa: other.qa)
    }
    
    init(zil: Zil) throws {
        try self.init(zil)
    }
    
    init(li: Li) throws {
        try self.init(li)
    }
    
    init(qa: Qa) throws {
        try self.init(qa)
    }
}

public extension ExpressibleByAmount where Self: Bound {
    init(zil zilString: String) throws {
        try self.init(zil: try Zil(trimming: zilString))
    }
    
    init(li liString: String) throws {
        try self.init(li: try Li(trimming: liString))
    }
    
    init(qa qaString: String) throws {
        try self.init(qa: try Qa(trimming: qaString))
    }
}

// MARK: - ExpressibleByFloatLiteral
public extension ExpressibleByAmount where Self: Bound {
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
    init(stringLiteral string: String) {
        do {
            try self = Self(trimming: string)
        } catch {
            fatalError("The `String` value (`\(string)`) passed was invalid, error: \(error)")
        }
    }
}

