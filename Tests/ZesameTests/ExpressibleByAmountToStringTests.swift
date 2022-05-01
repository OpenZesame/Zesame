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
    
    
    let decSep = Locale.current.decimalSeparatorForSure

    func testQa() {
        do {
            let big = try Amount(qa: "20999999999123567912432")
            let small = try Amount(qa: "510231481549")
            let expected = try Amount(qa: "20999999999633799393981")
            let expectedPlus1 = try Amount(qa: "20999999999633799393982")
            let expectedMinus1 = try Amount(qa: "20999999999633799393980")
            XCTAssertEqual(try big + small, expected)
            XCTAssertLessThan(try big + small, expectedPlus1)
            XCTAssertGreaterThan(try big + small, expectedMinus1)
        } catch {
            return XCTFail()
        }
    }

    func testRounding() {
        XCTAssertEqual(Amount(0.1449).asString(in: .zil, roundingIfNeeded: .down, roundingNumberOfDigits: 3), "0\(decSep)144")
        XCTAssertEqual(Amount(0.1449).asString(in: .zil, roundingIfNeeded: .up, roundingNumberOfDigits: 3), "0\(decSep)145")
    }

    func testSmallAmountAsZilString() {
        XCTAssertEqual(Amount(0.1).asString(in: .zil), "0\(decSep)1")
        XCTAssertEqual(Amount(0.49).asString(in: .zil), "0\(decSep)49")
        XCTAssertEqual(Amount(0.5).asString(in: .zil), "0\(decSep)5")
        XCTAssertEqual(Amount(0.51).asString(in: .zil), "0\(decSep)51")
        XCTAssertEqual(Amount(0).asString(in: .zil), "0")
        XCTAssertEqual(Amount(1).asString(in: .zil), "1")
        XCTAssertEqual(Amount(9).asString(in: .zil), "9")
    }

    func testSmallLiAsLiString() {
        XCTAssertEqual(Li(0.1).asString(in: .li), "0\(decSep)1")
        XCTAssertEqual(Li(0.1).asString(in: .zil), "0\(decSep)0000001")
        
        XCTAssertEqual(Li(0.49).asString(in: .li), "0\(decSep)49")
        XCTAssertEqual(Li(0.5).asString(in: .li), "0\(decSep)5")
        XCTAssertEqual(Li(0.51).asString(in: .li), "0\(decSep)51")
        
        XCTAssertEqual(Li(0.51).asString(in: .zil), "0\(decSep)00000051")
        XCTAssertEqual(Li(0).asString(in: .li), "0")
        XCTAssertEqual(Li(1).asString(in: .li), "1")
        XCTAssertEqual(Li(9).asString(in: .li), "9")
    }

    func testMazAmountAsZilString() {
        XCTAssertEqual(Amount(21_000_000_000).asString(in: .zil), "21000000000")
    }

    func test10LiInQaAsString() {
        XCTAssertEqual(Qa(10000000).asString(in: .li), "10")
    }
    
    func testQaToLiManyDecimals() {
        XCTAssertEqual(Qa(1).asString(in: .li), "0\(decSep)000001")
    }

    func testQaAsString() {
        XCTAssertEqual(Qa(1).asString(in: .qa), "1")
        XCTAssertEqual(Qa(1).asString(in: .zil), "0\(decSep)000000000001")

        XCTAssertEqual(Qa(10).asString(in: .qa), "10")
        XCTAssertEqual(Qa(10).asString(in: .li), "0\(decSep)00001")

        XCTAssertEqual(Qa(100).asString(in: .qa), "100")
        XCTAssertEqual(Qa(100).asString(in: .li), "0\(decSep)0001")
        XCTAssertEqual(Qa(100).asString(in: .zil), "0\(decSep)0000000001")

        XCTAssertEqual(Qa(1000).asString(in: .qa), "1000")
        XCTAssertEqual(Qa(1000).asString(in: .li), "0\(decSep)001")
        XCTAssertEqual(Qa(7000).asString(in: .zil), "0\(decSep)000000007")

        XCTAssertEqual(Qa(10005).asString(in: .qa), "10005")
        XCTAssertEqual(Qa(10000).asString(in: .li), "0\(decSep)01")
        XCTAssertEqual(Qa(50000).asString(in: .zil), "0\(decSep)00000005")

        XCTAssertEqual(Qa(100008).asString(in: .qa), "100008")
        XCTAssertEqual(Qa(100000).asString(in: .li), "0\(decSep)1")
        XCTAssertEqual(Qa(100000).asString(in: .zil), "0\(decSep)0000001")

        XCTAssertEqual(Qa(1000001).asString(in: .qa), "1000001")
        XCTAssertEqual(Qa(1000000).asString(in: .li), "1")
        XCTAssertEqual(Qa(1000000).asString(in: .zil), "0\(decSep)000001")

        XCTAssertEqual(Qa(10000004).asString(in: .qa), "10000004")
        XCTAssertEqual(Qa(10000000).asString(in: .li), "10")
        XCTAssertEqual(Qa(10000000).asString(in: .zil), "0\(decSep)00001")

        XCTAssertEqual(Qa(100000003).asString(in: .qa), "100000003")
        XCTAssertEqual(Qa(100000000).asString(in: .li), "100")
        XCTAssertEqual(Qa(100000000).asString(in: .zil), "0\(decSep)0001")

        XCTAssertEqual(Qa(1000000009).asString(in: .qa), "1000000009")
        XCTAssertEqual(Qa(1000000000).asString(in: .li), "1000")
        XCTAssertEqual(Qa(1000000000).asString(in: .zil), "0\(decSep)001")

        XCTAssertEqual(Qa(10000000002).asString(in: .qa), "10000000002")
        XCTAssertEqual(Qa(10000000000).asString(in: .li), "10000")
        XCTAssertEqual(Qa(10000000000).asString(in: .zil), "0\(decSep)01")

        XCTAssertEqual(Qa(700000005434).asString(in: .qa), "700000005434")
        XCTAssertEqual(Qa(674723000000).asString(in: .li), "674723")
        XCTAssertEqual(Qa(100000000000).asString(in: .zil), "0\(decSep)1")

        XCTAssertEqual(Qa(1000000000003).asString(in: .qa), "1000000000003")
        XCTAssertEqual(Qa(1000000000000).asString(in: .li), "1000000")
        XCTAssertEqual(Qa(1000000000000).asString(in: .zil), "1")

        XCTAssertEqual(Qa(10000000000007).asString(in: .qa), "10000000000007")
        XCTAssertEqual(Qa(10000005000000).asString(in: .li), "10000005")
        XCTAssertEqual(Qa(17000000000000).asString(in: .zil), "17")
    }
    
    func testThatFormattingUsesCorrectSeparator() {
        let amountString = "0\(decSep)01"
        XCTAssertEqual(try Zil(zil: amountString).asString(in: .zil), amountString)
    }
    
    func testDecimalStringAmount() {
        XCTAssertEqual(try Zil(zil: "0\(decSep)01").asString(in: .li), "10000")
    }
    
    func testThatStringOnlyContainingDecimalSeparatorThrowsError() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "\(Locale.current.decimalSeparatorForSure)"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testThatStringStartingWithDecimalSeparatorDefaultsToZero() {
        XCTAssertEqual(
            try Zil(zil: "\(decSep)1"),
            try Zil(zil: "0\(decSep)1")
        )
    }
    
    func testThatZilAsZilStringCanContainDecimals() {
        XCTAssertEqual(
            try Zil(zil: "0\(decSep)1").asString(in: .zil, roundingIfNeeded: nil),
            "0\(decSep)1"
        )
        
        XCTAssertEqual(try Zil(zil: "0\(decSep)0000000123").asQa, Qa(12300))
    }
    
    func testZilWithManyDecimalsToLiString() {
        XCTAssertEqual(
            try Zil(zil: "0\(decSep)0000000123").asString(in: .li, roundingIfNeeded: nil),
            "0\(decSep)0123"
        )
    }
    
    func testSmall() {
        XCTAssertEqual(try Qa(li: "0\(decSep)000015").asString(in: .qa, roundingIfNeeded: nil), "15")
    }
    
 
    
    func testTooSmallQaFromLi() {
        XCTAssertThrowsSpecificError(
            try Qa(li: "0\(Locale.current.decimalSeparatorForSure)0000001"),
            AmountError<Li>.tooManyDecimalPlaces
        )
    }
    
    func testTooSmallQaFromLiWrongSeparator() {
        let wrongSeparator = Locale.current.decimalSeparatorForSure == "." ? "," : "."
        let decimalStringWithWrongSep = "0\(wrongSeparator)0000001"
        XCTAssertThrowsSpecificError(
            try Qa(qa: decimalStringWithWrongSep),
            AmountError<Qa>.containsNonDecimalStringCharacter(disallowedCharacter: wrongSeparator)
        )
    }
    
    func testSmallQaFromLiString() {
        XCTAssertEqual(
            try Qa(li: "0\(decSep)000001"),
            Qa(1)
        )
    }
    
    func testTooSmallQaFromQaString() {
        XCTAssertThrowsSpecificError(
            try Qa(qa: "0\(decSep)1"),
            AmountError<Qa>.tooManyDecimalPlaces
        )
    }
    
    func testUntrimmedStringsNoTrimmingSpaces() {
        XCTAssertNoThrow(try Zil(trimming: "1 0"))
    }
    
    func testAmountFromDecimalStringWithLeadingZeroNoThrow() {
        XCTAssertNoThrow(try Zil(trimming: "1\(decSep)01"))
    }
    
    func testAmountFromDecimalStringWithLeadingZeroToString() {
        let zilString = "1\(decSep)01"
        XCTAssertEqual(try Zil(trimming: zilString).asString(in: .zil), zilString)
    }
    
    func testNotRemovingTrailingZero() {
        let zilString = "1\(decSep)0"
        XCTAssertEqual(try Zil(trimming: zilString).asString(in: .zil, minFractionDigits: 1), zilString)
    }
    
    func testThatAmountContainingOneGoodDecSepAndOneBadDoesNotThrowMoreThanOneSepErrorButRatherDisallowedCharsWarning() {
        let badSep = Locale.current.decimalSeparatorForSure == "." ? "," : "."
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1\(badSep)\(decSep)2"),
            AmountError<Zil>.containsNonDecimalStringCharacter(disallowedCharacter: badSep)
        )
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1\(decSep)\(badSep)2"),
            AmountError<Zil>.containsNonDecimalStringCharacter(disallowedCharacter: badSep)
        )
    }
    
    func testThatAmountContainingMoreThanOneDecimalSeparatorThrowsError() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1\(decSep)\(decSep)2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        XCTAssertThrowsSpecificError(
            try Zil(zil: "\(decSep)\(decSep)"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1\(decSep)\(decSep)\(decSep)2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "\(decSep)\(decSep)\(decSep)"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "\(decSep)1\(decSep)2"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1\(decSep)2\(decSep)3"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "\(decSep)1\(decSep)2\(decSep)"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "\(decSep)000\(decSep)"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "\(decSep)000\(decSep)0"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0\(decSep)000\(decSep)"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0\(decSep)000\(decSep)0"),
            AmountError<Zil>.moreThanOneDecimalSeparator
        )
    }
    
    func testQaToZil() {
        XCTAssertEqual(
            try Qa(qa: "1000000000").asZil,
            try Zil(zil: "0\(decSep)001")
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorAmount0() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "0\(decSep)"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Amount(zil: "0\(decSep)"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorAmount1() {
        XCTAssertThrowsSpecificError(
            try Zil(zil: "1\(decSep)"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
        
        XCTAssertThrowsSpecificError(
            try Amount(zil: "1\(decSep)"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorLiFromAmount0() {
        XCTAssertThrowsSpecificError(
            try Li(zil: "0\(decSep)"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorLiFromAmount1() {
        XCTAssertThrowsSpecificError(
            try Li(zil: "1\(decSep)"),
            AmountError<Zil>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorLiAmount0() {
        XCTAssertThrowsSpecificError(
            try Li(li: "0\(decSep)"),
            AmountError<Li>.endsWithDecimalSeparator
        )
    }
    
    func testThatDecimalStringEndingWithDecimalSeparatorThrowsErrorLiAmount1() {
        XCTAssertThrowsSpecificError(
            try Li(li: "1\(decSep)"),
            AmountError<Li>.endsWithDecimalSeparator
        )
    }

    func testLiAsString() {
        XCTAssertEqual(Li(1).asString(in: .qa), "1000000")
        XCTAssertEqual(Li(1).asString(in: .li), "1")
        XCTAssertEqual(Li(1).asString(in: .zil), "0\(decSep)000001")

        XCTAssertEqual(Li(10).asString(in: .qa), "10000000")
        XCTAssertEqual(Li(10).asString(in: .li), "10")
        XCTAssertEqual(Li(10).asString(in: .zil), "0\(decSep)00001")

        XCTAssertEqual(Li(100).asString(in: .qa), "100000000")
        XCTAssertEqual(Li(100).asString(in: .li), "100")
        XCTAssertEqual(Li(100).asString(in: .zil), "0\(decSep)0001")

        XCTAssertEqual(Li(1000).asString(in: .qa), "1000000000")
        XCTAssertEqual(Li(1000).asString(in: .li), "1000")
        XCTAssertEqual(Li(1000).asString(in: .zil), "0\(decSep)001")

        XCTAssertEqual(Li(10000).asString(in: .qa), "10000000000")
        XCTAssertEqual(Li(10000).asString(in: .li), "10000")
        XCTAssertEqual(Li(10000).asString(in: .zil), "0\(decSep)01")

        XCTAssertEqual(Li(100000).asString(in: .qa), "100000000000")
        XCTAssertEqual(Li(100000).asString(in: .li), "100000")
        XCTAssertEqual(Li(100000).asString(in: .zil), "0\(decSep)1")

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
    }
    
    func testBiggerThanTotalSupplyManyDigits() {
        XCTAssertEqual(Zil(39085000499).asString(in: .zil), "39085000499")
    }

}

