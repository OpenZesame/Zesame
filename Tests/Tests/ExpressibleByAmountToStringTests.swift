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

class ExpressibleByAmountToStringTests: XCTestCase {

    func testQa() {
        do {
            let big = try ZilAmount(qa: "20999999999123567912432")
            let small = try ZilAmount(qa: "510231481549")
            let expected = try ZilAmount(qa: "20999999999633799393981")
            let expectedPlus1 = try ZilAmount(qa: "20999999999633799393982")
            let expectedMinus1 = try ZilAmount(qa: "20999999999633799393980")
            XCTAssertEqual(try big + small, expected)
            XCTAssertLessThan(try big + small, expectedPlus1)
            XCTAssertGreaterThan(try big + small, expectedMinus1)
        } catch {
            return XCTFail()
        }
    }

    func testSmallZilAmountAsZilString() {
        XCTAssertEqual(ZilAmount(0.1).asString(in: .zil), "0")
        XCTAssertEqual(ZilAmount(0.1).asString(in: .zil, roundingIfNeeded: .down), "0")
        XCTAssertEqual(ZilAmount(0.1).asString(in: .zil, roundingIfNeeded: .up), "1")
        XCTAssertEqual(ZilAmount(0.49).asString(in: .zil), "0")
        XCTAssertEqual(ZilAmount(0.5).asString(in: .zil), "1")
        XCTAssertEqual(ZilAmount(0.51).asString(in: .zil), "1")
        XCTAssertEqual(ZilAmount(0).asString(in: .zil), "0")
        XCTAssertEqual(ZilAmount(1).asString(in: .zil), "1")
        XCTAssertEqual(ZilAmount(9).asString(in: .zil), "9")
    }


    func testSmallLiAsLiString() {
        XCTAssertEqual(Li(0.1).asString(in: .li), "0")
        XCTAssertEqual(Li(0.1).asString(in: .zil), "0.0000001")
        XCTAssertEqual(Li(0.49).asString(in: .li), "0")
        XCTAssertEqual(Li(0.5).asString(in: .li), "1")
        XCTAssertEqual(Li(0.51).asString(in: .li), "1")
        XCTAssertEqual(Li(0.51).asString(in: .zil), "0.00000051")
        XCTAssertEqual(Li(0).asString(in: .li), "0")
        XCTAssertEqual(Li(1).asString(in: .li), "1")
        XCTAssertEqual(Li(9).asString(in: .li), "9")
    }

    func testMazZilAmountAsZilString() {
        XCTAssertEqual(ZilAmount(21_000_000_000).asString(in: .zil), "21000000000")
    }

    func test10LiInQaAsString() {
        XCTAssertEqual(Qa(10000000).asString(in: .li), "10")
    }

    func testQaAsString() {
        XCTAssertEqual(Qa(1).asString(in: .qa), "1")
        XCTAssertEqual(Qa(1).asString(in: .li), "0.000001")
        XCTAssertEqual(Qa(1).asString(in: .zil), "0.000000000001")

        XCTAssertEqual(Qa(10).asString(in: .qa), "10")
        XCTAssertEqual(Qa(10).asString(in: .li), "0.00001")

        XCTAssertEqual(Qa(100).asString(in: .qa), "100")
        XCTAssertEqual(Qa(100).asString(in: .li), "0.0001")
        XCTAssertEqual(Qa(100).asString(in: .zil), "0.0000000001")

        XCTAssertEqual(Qa(1000).asString(in: .qa), "1000")
        XCTAssertEqual(Qa(1000).asString(in: .li), "0.001")
        XCTAssertEqual(Qa(7000).asString(in: .zil), "0.000000007")

        XCTAssertEqual(Qa(10005).asString(in: .qa), "10005")
        XCTAssertEqual(Qa(10000).asString(in: .li), "0.01")
        XCTAssertEqual(Qa(50000).asString(in: .zil), "0.00000005")

        XCTAssertEqual(Qa(100008).asString(in: .qa), "100008")
        XCTAssertEqual(Qa(100000).asString(in: .li), "0.1")
        XCTAssertEqual(Qa(100000).asString(in: .zil), "0.0000001")

        XCTAssertEqual(Qa(1000001).asString(in: .qa), "1000001")
        XCTAssertEqual(Qa(1000000).asString(in: .li), "1")
        XCTAssertEqual(Qa(1000000).asString(in: .zil), "0.000001")

        XCTAssertEqual(Qa(10000004).asString(in: .qa), "10000004")
        XCTAssertEqual(Qa(10000000).asString(in: .li), "10")
        XCTAssertEqual(Qa(10000000).asString(in: .zil), "0.00001")

        XCTAssertEqual(Qa(100000003).asString(in: .qa), "100000003")
        XCTAssertEqual(Qa(100000000).asString(in: .li), "100")
        XCTAssertEqual(Qa(100000000).asString(in: .zil), "0.0001")

        XCTAssertEqual(Qa(1000000009).asString(in: .qa), "1000000009")
        XCTAssertEqual(Qa(1000000000).asString(in: .li), "1000")
        XCTAssertEqual(Qa(1000000000).asString(in: .zil), "0.001")

        XCTAssertEqual(Qa(10000000002).asString(in: .qa), "10000000002")
        XCTAssertEqual(Qa(10000000000).asString(in: .li), "10000")
        XCTAssertEqual(Qa(10000000000).asString(in: .zil), "0.01")

        XCTAssertEqual(Qa(700000005434).asString(in: .qa), "700000005434")
        XCTAssertEqual(Qa(674723000000).asString(in: .li), "674723")
        XCTAssertEqual(Qa(100000000000).asString(in: .zil), "0.1")

        XCTAssertEqual(Qa(1000000000003).asString(in: .qa), "1000000000003")
        XCTAssertEqual(Qa(1000000000000).asString(in: .li), "1000000")
        XCTAssertEqual(Qa(1000000000000).asString(in: .zil), "1")

        XCTAssertEqual(Qa(10000000000007).asString(in: .qa), "10000000000007")
        XCTAssertEqual(Qa(10000005000000).asString(in: .li), "10000005")
        XCTAssertEqual(Qa(17000000000000).asString(in: .zil), "17")
    }
    
    func testDecimalStringZilAmount() {
        XCTAssertEqual(try Zil(zil: "0.01").asString(in: .li), "10000")
        XCTAssertEqual(try Zil(zil: "0,01").asString(in: .li), "10000")
        XCTAssertEqual(try ZilAmount(zil: "0.01").asString(in: .li), "10000")
        XCTAssertEqual(try ZilAmount(zil: "0,01").asString(in: .li), "10000")
    }
    
    func testThatStringOnlyContainingDecimalSeparatorThrowsError() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "."),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ","),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testCommaAndDotAsDecimalSeparatorEquals() {
        XCTAssertEqual(
            try Zil(zil: "0.1"),
            try Zil(zil: "0,1")
        )
    }
    
    func testThatStringStartingWithDecimalSeparatorDefaultsToZero() {
        
        
        XCTAssertEqual(
            try Zil(zil: ".1"),
            try Zil(zil: "0.1")
        )
        
        XCTAssertEqual(
            try Zil(zil: ",1"),
            try Zil(zil: "0,1")
        )
    }
    
    func testThatZilAsZilStringCanContainDecimals() {
        XCTAssertEqual(
            try Zil(zil: "0.1").asString(in: .zil, roundingIfNeeded: nil),
            "0.1"
        )
        
        XCTAssertEqual(try Zil(zil: "0.0000000123").asQa, Qa(12300))
    }
    
    func testZilWithManyDecimalsToLiString() {
        XCTAssertEqual(
            try Zil(zil: "0.0000000123").asString(in: .li, roundingIfNeeded: nil),
            "0.0123"
        )
    }
    
    func testSmall() {
        XCTAssertEqual(try Qa(li: "0.000015").asString(in: .qa, roundingIfNeeded: nil), "15")
    }
    
 
    
    func testTooSmallQaFromLi() {
        XCTAssertThrowsSpecificError(
            try Qa(li: "0.0000001"),
            AmountError<Li>.tooManyDecimalPlaces
        )
        
        XCTAssertEqual(
         try Qa(li: "0.000001"),
            Qa(1)
        )
    }
    
    func testTooSmallQaFromQaString() {
        XCTAssertThrowsSpecificError(
            try Qa(qa: "0.1"),
            AmountError<Qa>.tooManyDecimalPlaces
        )
    }
    
    func testThatAmountContainingMoreThanOneDecimalSeparatorThrowsErrorDot() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1..2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        XCTAssertThrowsSpecificError(
            try Zil(zil: ".."),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1...2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "..."),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ".1.2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1.2.3"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ".1.2."),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ".000."),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ".000.0"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0.000."),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0.000.0"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
    }
    
    func testUntrimmedStringsNoTrimmingSpaces() {
        XCTAssertNoThrow(try Zil(trimming: "1 0"))
        
        XCTAssertThrowsSpecificError(
            try Zil(trimming: "1 0") { $0 /* no trimming at all */ },
            AmountError<Zil>.nonNumericString
        )
    }
    
    func testUntrimmedStringsNoTrimmingCommaSeparator() {
        guard Locale.current.decimalSeparatorForSure == "." || Locale.current.decimalSeparatorForSure == "," else {
            return
        }
        
        let wrongSeparator = Locale.current.decimalSeparatorForSure == "." ? "," : "."
        
        XCTAssertNotEqual(Locale.current.decimalSeparatorForSure, wrongSeparator)

        let amountStringWithWrongSeparator = "1\(wrongSeparator)0"

        XCTAssertNoThrow(try Zil(trimming: amountStringWithWrongSeparator))

        XCTAssertThrowsSpecificError(
            try Zil(trimming: amountStringWithWrongSeparator) { $0 /* no trimming at all */ },
            AmountError<Zil>.nonNumericString
        )
        
        XCTAssertThrowsSpecificError(
            // Forcing wrong decimalSeparator => cannot create Decimal number since it will continue
            // to contain an incorrect char, the `wrongSeparator`
            try Zil(untrimmed: amountStringWithWrongSeparator, decimalSeparator: wrongSeparator),
            AmountError<Zil>.nonNumericString
        )
        
        XCTAssertNoThrow(
            // This is in fact the default behaviour, trimming the string using the decimalSeparator
            // of the current `Locale`, which will result in an accuratly trimmed string
            // from which we will be able to create a decimal number.
            try Zil(untrimmed: amountStringWithWrongSeparator, decimalSeparator: Locale.current.decimalSeparatorForSure)
        )
    }
        
    func testThatAmountContainingMoreThanOneDecimalSeparatorThrowsErrorMixed() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1.,2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        XCTAssertThrowsSpecificError(
            try Zil(zil: ".,"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1.,.2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ".,."),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ".1,2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1,2.3"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ",1.2."),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ",000."),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ",000.0"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0.000,"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0,000.0"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
    }
    
    func testThatAmountContainingMoreThanOneDecimalSeparatorThrowsErrorComma() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1,,2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        XCTAssertThrowsSpecificError(
            try Zil(zil: ",,"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1,,,2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ",,,"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ",1,2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1,2,3"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ",1,2,"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ",000,"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: ",000,0"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0,000,"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0,000,0"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
    }
    
    func testQaToZil() {
        XCTAssertEqual(
            try Qa(qa: "1000000000").asZil,
            try Zil(zil: "0.001")
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorZilAmount0() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0."),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0,"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try ZilAmount(zil: "0."),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try ZilAmount(zil: "0,"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorZilAmount1() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1."),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1,"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try ZilAmount(zil: "1."),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try ZilAmount(zil: "1,"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorLiFromZilAmount0() {
        XCTAssertThrowsSpecificError(
            try Li(zil: "0."),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Li(zil: "0,"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorLiFromZilAmount1() {
        XCTAssertThrowsSpecificError(
            try Li(zil: "1."),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Li(zil: "1,"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorLiAmount0() {
        XCTAssertThrowsSpecificError(
            try Li(li: "0."),
            AmountError<Li>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Li(li: "0,"),
            AmountError<Li>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorLiAmount1() {
        XCTAssertThrowsSpecificError(
            try Li(li: "1."),
            AmountError<Li>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Li(li: "1,"),
            AmountError<Li>.endsWithDecimalSeparator
        )
    }

    func testLiAsString() {
        XCTAssertEqual(Li(1).asString(in: .qa), "1000000")
        XCTAssertEqual(Li(1).asString(in: .li), "1")
        XCTAssertEqual(Li(1).asString(in: .zil), "0.000001")

        XCTAssertEqual(Li(10).asString(in: .qa), "10000000")
        XCTAssertEqual(Li(10).asString(in: .li), "10")
        XCTAssertEqual(Li(10).asString(in: .zil), "0.00001")

        XCTAssertEqual(Li(100).asString(in: .qa), "100000000")
        XCTAssertEqual(Li(100).asString(in: .li), "100")
        XCTAssertEqual(Li(100).asString(in: .zil), "0.0001")

        XCTAssertEqual(Li(1000).asString(in: .qa), "1000000000")
        XCTAssertEqual(Li(1000).asString(in: .li), "1000")
        XCTAssertEqual(Li(1000).asString(in: .zil), "0.001")

        XCTAssertEqual(Li(10000).asString(in: .qa), "10000000000")
        XCTAssertEqual(Li(10000).asString(in: .li), "10000")
        XCTAssertEqual(Li(10000).asString(in: .zil), "0.01")

        XCTAssertEqual(Li(100000).asString(in: .qa), "100000000000")
        XCTAssertEqual(Li(100000).asString(in: .li), "100000")
        XCTAssertEqual(Li(100000).asString(in: .zil), "0.1")

        XCTAssertEqual(Li(1000000).asString(in: .qa), "1000000000000")
        XCTAssertEqual(Li(1000000).asString(in: .li), "1000000")
        XCTAssertEqual(Li(1000000).asString(in: .zil), "1")

        XCTAssertEqual(Li(10000000).asString(in: .qa), "10000000000000")
        XCTAssertEqual(Li(10000000).asString(in: .li), "10000000")
        XCTAssertEqual(Li(10000000).asString(in: .zil), "10")

        XCTAssertEqual(Li(100000000).asString(in: .qa), "100000000000000")
        XCTAssertEqual(Li(100000000).asString(in: .li), "100000000")
        XCTAssertEqual(Li(987000000).asString(in: .zil), "987")

        XCTAssertEqual(Li(1000000000).asString(in: .qa), "1000000000000000")
        XCTAssertEqual(Li(1000000000).asString(in: .li), "1000000000")
        XCTAssertEqual(Li(4321000000).asString(in: .zil), "4321")

        XCTAssertEqual(Li(10000000000).asString(in: .qa), "10000000000000000")
        XCTAssertEqual(Li(10000000000).asString(in: .li), "10000000000")
        XCTAssertEqual(Li(10000000000).asString(in: .zil), "10000")

        XCTAssertEqual(Li(100000000000).asString(in: .qa), "100000000000000000")
        XCTAssertEqual(Li(100000000000).asString(in: .li), "100000000000")
        XCTAssertEqual(Li(106078000000).asString(in: .zil), "106078")

        XCTAssertEqual(Li(1000000000000).asString(in: .qa), "1000000000000000000")
        XCTAssertEqual(Li(1000000000000).asString(in: .li), "1000000000000")
        XCTAssertEqual(Li(1000000000000).asString(in: .zil), "1000000")

        XCTAssertEqual(Li(10000000000000).asString(in: .qa), "10000000000000000000")
        XCTAssertEqual(Li(10000000000000).asString(in: .li), "10000000000000")
        XCTAssertEqual(Li(10000000000000).asString(in: .zil), "10000000")
    }

    func testZilAsString() {
        XCTAssertEqual(Zil(1).asString(in: .qa), "1000000000000")
        XCTAssertEqual(Zil(1).asString(in: .li), "1000000")
        XCTAssertEqual(Zil(1).asString(in: .zil), "1")

        XCTAssertEqual(Zil(10).asString(in: .qa), "10000000000000")
        XCTAssertEqual(Zil(10).asString(in: .li), "10000000")
        XCTAssertEqual(Zil(10).asString(in: .zil), "10")

        XCTAssertEqual(Zil(100).asString(in: .qa), "100000000000000")
        XCTAssertEqual(Zil(100).asString(in: .li), "100000000")
        XCTAssertEqual(Zil(100).asString(in: .zil), "100")

        XCTAssertEqual(Zil(1000).asString(in: .qa), "1000000000000000")
        XCTAssertEqual(Zil(1000).asString(in: .li), "1000000000")
        XCTAssertEqual(Zil(1234).asString(in: .zil), "1234")

        XCTAssertEqual(Zil(10000).asString(in: .qa), "10000000000000000")
        XCTAssertEqual(Zil(10000).asString(in: .li), "10000000000")
        XCTAssertEqual(Zil(10000).asString(in: .zil), "10000")

        XCTAssertEqual(Zil(100000).asString(in: .qa), "100000000000000000")
        XCTAssertEqual(Zil(100000).asString(in: .li), "100000000000")
        XCTAssertEqual(Zil(12345).asString(in: .zil), "12345")

        XCTAssertEqual(Zil(1000000).asString(in: .qa), "1000000000000000000")
        XCTAssertEqual(Zil(1000000).asString(in: .li), "1000000000000")
        XCTAssertEqual(Zil(123456).asString(in: .zil), "123456")

        XCTAssertEqual(Zil(1234567).asString(in: .qa), "1234567000000000000")
        XCTAssertEqual(Zil(1234567).asString(in: .li), "1234567000000")
        XCTAssertEqual(Zil(1234567).asString(in: .zil), "1234567")

        XCTAssertEqual(Zil(100000000).asString(in: .qa), "100000000000000000000")
        XCTAssertEqual(Zil(100000000).asString(in: .li), "100000000000000")
        XCTAssertEqual(Zil(987000000).asString(in: .zil), "987000000")

        XCTAssertEqual(Zil(9000000000).asString(in: .qa), "9000000000000000000000")
        XCTAssertEqual(Zil(9000000000).asString(in: .li), "9000000000000000")
        XCTAssertEqual(Zil(9085000000).asString(in: .zil), "9085000000")

        // bigger than total supply
        XCTAssertEqual(Zil(39000000009).asString(in: .qa), "39000000009000000000000")
        XCTAssertEqual(Zil(39000000004).asString(in: .li), "39000000004000000")
        XCTAssertEqual(Zil(39085000499).asString(in: .zil), "39085000499")
    }

}
