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
import Testing
@testable import Zesame

struct StringCommaSeparatorFunctionsTests {
    private let decSep = Locale.current.decimalSeparatorForSure

    @Test func doubleFormattingContainsLocaleDecimalSeparator() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(Double(0.1).asString() == "0\(decSep)1")
    }

    @Test func stringDecimalPlaces() {
        #expect("1".countDecimalPlaces() == 0)
        #expect("1337".countDecimalPlaces() == 0)
        #expect("0".countDecimalPlaces() == 0)
        #expect(Double(0.01).asString(maxFractionDigits: 2).countDecimalPlaces() == 2)
        #expect(Double(0.01).asString(maxFractionDigits: 9).countDecimalPlaces() == 2)
        #expect(Double(0.001).asString(maxFractionDigits: 9).countDecimalPlaces() == 3)
        #expect(Double(0.0001).asString(maxFractionDigits: 9).countDecimalPlaces() == 4)
    }

    @Test func stringContainMoreThanOneSeparator() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect("1\(decSep)2".doesNotContainMoreThanOneDecimalSeparator())
        #expect(!"1\(decSep)\(decSep)2".doesNotContainMoreThanOneDecimalSeparator())
    }

    @Test func stringCharsAsStrings() {
        #expect("ABC".charactersAsStrings() == ["A", "B", "C"])
    }
}

private extension Double {
    func asString(maxFractionDigits: Int = 2) -> String {
        let nsDecimalNumber = NSDecimalNumber(floatLiteral: self)
        guard let string = asStringUsingLocalizedDecimalSeparator(
            nsDecimalNumber: nsDecimalNumber,
            maxFractionDigits: maxFractionDigits
        ) else {
            fatalError("should be able to format string from double")
        }
        return string
    }
}
