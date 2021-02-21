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
import XCTest
import BigInt
@testable import Zesame

class StringCommaSeparatorFunctionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    

    func testDoubleFormattingContainsLocaleDecimalSeparator() {
        XCTAssertEqual(Double(0.1).asString(), "0\(Locale.current.decimalSeparatorForSure)1")
    }
    
    func testStringDecimalPlaces() {
        XCTAssertEqual("1".countDecimalPlaces(), 0)
        XCTAssertEqual("1337".countDecimalPlaces(), 0)
        XCTAssertEqual("0".countDecimalPlaces(), 0)
        XCTAssertEqual(Double(0.01).asString(maxFractionDigits: 2).countDecimalPlaces(), 2)
        XCTAssertEqual(Double(0.01).asString(maxFractionDigits: 9).countDecimalPlaces(), 2)
        XCTAssertEqual(Double(0.001).asString(maxFractionDigits: 9).countDecimalPlaces(), 3)
        XCTAssertEqual(Double(0.0001).asString(maxFractionDigits: 9).countDecimalPlaces(), 4)
    }
    
    func testStringContainMoreThanOneSeparator() {
        XCTAssertTrue(
            "1\(decSep)2".doesNotContainMoreThanOneDecimalSeparator()
        )
        XCTAssertFalse(
            "1\(decSep)\(decSep)2".doesNotContainMoreThanOneDecimalSeparator()
        )
    }
    
    func testStringCharsAsStrings() {
        func doTest(string: String, expected: [String], function: (String) -> () -> [String]) {
            XCTAssertEqual(
                function(string)(), expected
            )
        }
        doTest(string: "ABC", expected: ["A", "B", "C"], function: String.charactersAsStrings)
            
    }
}

private let decSep = Locale.current.decimalSeparatorForSure

private extension Double {
    func asString(maxFractionDigits: Int = 2) -> String {
        let nsDecimalNumber = NSDecimalNumber(floatLiteral: self)
        guard let string = asStringUsingLocalizedDecimalSeparator(nsDecimalNumber: nsDecimalNumber, maxFractionDigits: maxFractionDigits) else {
            fatalError("should be able to format string from double")
        }
        return string
    }
}
