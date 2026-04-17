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

import BigInt
import Foundation
import Testing
@testable import Zesame

// MARK: - Parameterized vector types

struct QaCase {
    let qa: Qa
    let unit: Zesame.Unit
    let expected: String
}

struct LiCase {
    let li: Li
    let unit: Zesame.Unit
    let expected: String
}

struct ZilCase {
    let zil: Zil
    let unit: Zesame.Unit
    let expected: String
}

// MARK: - Test data

private extension QaCase {
    static var all: [QaCase] {
        let d = Locale.current.decimalSeparatorForSure
        return [
            QaCase(qa: Qa(1), unit: Zesame.Unit.qa, expected: "1"),
            QaCase(qa: Qa(1), unit: .zil, expected: "0\(d)000000000001"),
            QaCase(qa: Qa(10), unit: .qa, expected: "10"),
            QaCase(qa: Qa(10), unit: .li, expected: "0\(d)00001"),
            QaCase(qa: Qa(100), unit: .qa, expected: "100"),
            QaCase(qa: Qa(100), unit: .li, expected: "0\(d)0001"),
            QaCase(qa: Qa(100), unit: .zil, expected: "0\(d)0000000001"),
            QaCase(qa: Qa(1000), unit: .qa, expected: "1000"),
            QaCase(qa: Qa(1000), unit: .li, expected: "0\(d)001"),
            QaCase(qa: Qa(7000), unit: .zil, expected: "0\(d)000000007"),
            QaCase(qa: Qa(10005), unit: .qa, expected: "10005"),
            QaCase(qa: Qa(10000), unit: .li, expected: "0\(d)01"),
            QaCase(qa: Qa(50000), unit: .zil, expected: "0\(d)00000005"),
            QaCase(qa: Qa(100_008), unit: .qa, expected: "100008"),
            QaCase(qa: Qa(100_000), unit: .li, expected: "0\(d)1"),
            QaCase(qa: Qa(100_000), unit: .zil, expected: "0\(d)0000001"),
            QaCase(qa: Qa(1_000_001), unit: .qa, expected: "1000001"),
            QaCase(qa: Qa(1_000_000), unit: .li, expected: "1"),
            QaCase(qa: Qa(1_000_000), unit: .zil, expected: "0\(d)000001"),
            QaCase(qa: Qa(10_000_004), unit: .qa, expected: "10000004"),
            QaCase(qa: Qa(10_000_000), unit: .li, expected: "10"),
            QaCase(qa: Qa(10_000_000), unit: .zil, expected: "0\(d)00001"),
            QaCase(qa: Qa(100_000_003), unit: .qa, expected: "100000003"),
            QaCase(qa: Qa(100_000_000), unit: .li, expected: "100"),
            QaCase(qa: Qa(100_000_000), unit: .zil, expected: "0\(d)0001"),
            QaCase(qa: Qa(1_000_000_009), unit: .qa, expected: "1000000009"),
            QaCase(qa: Qa(1_000_000_000), unit: .li, expected: "1000"),
            QaCase(qa: Qa(1_000_000_000), unit: .zil, expected: "0\(d)001"),
            QaCase(qa: Qa(10_000_000_002), unit: .qa, expected: "10000000002"),
            QaCase(qa: Qa(10_000_000_000), unit: .li, expected: "10000"),
            QaCase(qa: Qa(10_000_000_000), unit: .zil, expected: "0\(d)01"),
            QaCase(qa: Qa(700_000_005_434), unit: .qa, expected: "700000005434"),
            QaCase(qa: Qa(674_723_000_000), unit: .li, expected: "674723"),
            QaCase(qa: Qa(100_000_000_000), unit: .zil, expected: "0\(d)1"),
            QaCase(qa: Qa(1_000_000_000_003), unit: .qa, expected: "1000000000003"),
            QaCase(qa: Qa(1_000_000_000_000), unit: .li, expected: "1000000"),
            QaCase(qa: Qa(1_000_000_000_000), unit: .zil, expected: "1"),
            QaCase(qa: Qa(10_000_000_000_007), unit: .qa, expected: "10000000000007"),
            QaCase(qa: Qa(10_000_005_000_000), unit: .li, expected: "10000005"),
            QaCase(qa: Qa(17_000_000_000_000), unit: .zil, expected: "17"),
        ]
    }
}

private extension LiCase {
    static var all: [LiCase] {
        let d = Locale.current.decimalSeparatorForSure
        return [
            LiCase(li: Li(1), unit: .qa, expected: "1000000"),
            LiCase(li: Li(1), unit: .li, expected: "1"),
            LiCase(li: Li(1), unit: .zil, expected: "0\(d)000001"),
            LiCase(li: Li(10), unit: .qa, expected: "10000000"),
            LiCase(li: Li(10), unit: .li, expected: "10"),
            LiCase(li: Li(10), unit: .zil, expected: "0\(d)00001"),
            LiCase(li: Li(100), unit: .qa, expected: "100000000"),
            LiCase(li: Li(100), unit: .li, expected: "100"),
            LiCase(li: Li(100), unit: .zil, expected: "0\(d)0001"),
            LiCase(li: Li(1000), unit: .qa, expected: "1000000000"),
            LiCase(li: Li(1000), unit: .li, expected: "1000"),
            LiCase(li: Li(1000), unit: .zil, expected: "0\(d)001"),
            LiCase(li: Li(10000), unit: .qa, expected: "10000000000"),
            LiCase(li: Li(10000), unit: .li, expected: "10000"),
            LiCase(li: Li(10000), unit: .zil, expected: "0\(d)01"),
            LiCase(li: Li(100_000), unit: .qa, expected: "100000000000"),
            LiCase(li: Li(100_000), unit: .li, expected: "100000"),
            LiCase(li: Li(100_000), unit: .zil, expected: "0\(d)1"),
            LiCase(li: Li(1_000_000), unit: .qa, expected: "1000000000000"),
            LiCase(li: Li(1_000_000), unit: .li, expected: "1000000"),
            LiCase(li: Li(1_000_000), unit: .zil, expected: "1"),
            LiCase(li: Li(10_000_000), unit: .qa, expected: "10000000000000"),
            LiCase(li: Li(10_000_000), unit: .li, expected: "10000000"),
            LiCase(li: Li(10_000_000), unit: .zil, expected: "10"),
            LiCase(li: Li(100_000_000), unit: .qa, expected: "100000000000000"),
            LiCase(li: Li(100_000_000), unit: .li, expected: "100000000"),
            LiCase(li: Li(987_000_000), unit: .zil, expected: "987"),
            LiCase(li: Li(1_000_000_000), unit: .qa, expected: "1000000000000000"),
            LiCase(li: Li(1_000_000_000), unit: .li, expected: "1000000000"),
            LiCase(li: Li(4_321_000_000), unit: .zil, expected: "4321"),
            LiCase(li: Li(10_000_000_000), unit: .qa, expected: "10000000000000000"),
            LiCase(li: Li(10_000_000_000), unit: .li, expected: "10000000000"),
            LiCase(li: Li(10_000_000_000), unit: .zil, expected: "10000"),
            LiCase(li: Li(100_000_000_000), unit: .qa, expected: "100000000000000000"),
            LiCase(li: Li(100_000_000_000), unit: .li, expected: "100000000000"),
            LiCase(li: Li(106_078_000_000), unit: .zil, expected: "106078"),
            LiCase(li: Li(1_000_000_000_000), unit: .qa, expected: "1000000000000000000"),
            LiCase(li: Li(1_000_000_000_000), unit: .li, expected: "1000000000000"),
            LiCase(li: Li(1_000_000_000_000), unit: .zil, expected: "1000000"),
            LiCase(li: Li(10_000_000_000_000), unit: .qa, expected: "10000000000000000000"),
            LiCase(li: Li(10_000_000_000_000), unit: .li, expected: "10000000000000"),
            LiCase(li: Li(10_000_000_000_000), unit: .zil, expected: "10000000"),
        ]
    }
}

private extension ZilCase {
    static var all: [ZilCase] {
        [
            ZilCase(zil: Zil(1), unit: .qa, expected: "1000000000000"),
            ZilCase(zil: Zil(1), unit: .li, expected: "1000000"),
            ZilCase(zil: Zil(1), unit: .zil, expected: "1"),
            ZilCase(zil: Zil(10), unit: .qa, expected: "10000000000000"),
            ZilCase(zil: Zil(10), unit: .li, expected: "10000000"),
            ZilCase(zil: Zil(10), unit: .zil, expected: "10"),
            ZilCase(zil: Zil(100), unit: .qa, expected: "100000000000000"),
            ZilCase(zil: Zil(100), unit: .li, expected: "100000000"),
            ZilCase(zil: Zil(100), unit: .zil, expected: "100"),
            ZilCase(zil: Zil(1000), unit: .qa, expected: "1000000000000000"),
            ZilCase(zil: Zil(1000), unit: .li, expected: "1000000000"),
            ZilCase(zil: Zil(1234), unit: .zil, expected: "1234"),
            ZilCase(zil: Zil(10000), unit: .qa, expected: "10000000000000000"),
            ZilCase(zil: Zil(10000), unit: .li, expected: "10000000000"),
            ZilCase(zil: Zil(10000), unit: .zil, expected: "10000"),
            ZilCase(zil: Zil(100_000), unit: .qa, expected: "100000000000000000"),
            ZilCase(zil: Zil(100_000), unit: .li, expected: "100000000000"),
            ZilCase(zil: Zil(12345), unit: .zil, expected: "12345"),
            ZilCase(zil: Zil(1_000_000), unit: .qa, expected: "1000000000000000000"),
            ZilCase(zil: Zil(1_000_000), unit: .li, expected: "1000000000000"),
            ZilCase(zil: Zil(123_456), unit: .zil, expected: "123456"),
            ZilCase(zil: Zil(1_234_567), unit: .qa, expected: "1234567000000000000"),
            ZilCase(zil: Zil(1_234_567), unit: .li, expected: "1234567000000"),
            ZilCase(zil: Zil(1_234_567), unit: .zil, expected: "1234567"),
            ZilCase(zil: Zil(100_000_000), unit: .qa, expected: "100000000000000000000"),
            ZilCase(zil: Zil(100_000_000), unit: .li, expected: "100000000000000"),
            ZilCase(zil: Zil(987_000_000), unit: .zil, expected: "987000000"),
            ZilCase(zil: Zil(9_000_000_000), unit: .qa, expected: "9000000000000000000000"),
            ZilCase(zil: Zil(9_000_000_000), unit: .li, expected: "9000000000000000"),
            ZilCase(zil: Zil(9_085_000_000), unit: .zil, expected: "9085000000"),
            ZilCase(zil: Zil(39_000_000_009), unit: .qa, expected: "39000000009000000000000"),
            ZilCase(zil: Zil(39_000_000_004), unit: .li, expected: "39000000004000000"),
            ZilCase(zil: Zil(39_085_000_499), unit: .zil, expected: "39085000499"),
        ]
    }
}

// MARK: - Tests

struct ExpressibleByAmountToStringTests {
    @Test func qa() throws {
        let big = try ZilAmount(qa: "20999999999123567912432")
        let small = try ZilAmount(qa: "510231481549")
        let expected = try ZilAmount(qa: "20999999999633799393981")
        let expectedPlus1 = try ZilAmount(qa: "20999999999633799393982")
        let expectedMinus1 = try ZilAmount(qa: "20999999999633799393980")
        #expect(try big + small == expected)
        #expect(try big + small < expectedPlus1)
        #expect(try big + small > expectedMinus1)
    }

    @Test func rounding() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(
            ZilAmount(0.1449).asString(in: .zil, roundingIfNeeded: .down, roundingNumberOfDigits: 3)
                == "0\(decSep)144"
        )
        #expect(
            ZilAmount(0.1449).asString(in: .zil, roundingIfNeeded: .up, roundingNumberOfDigits: 3)
                == "0\(decSep)145"
        )
    }

    @Test func smallZilAmountAsZilString() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(ZilAmount(0.1).asString(in: .zil) == "0\(decSep)1")
        #expect(ZilAmount(0.49).asString(in: .zil) == "0\(decSep)49")
        #expect(ZilAmount(0.5).asString(in: .zil) == "0\(decSep)5")
        #expect(ZilAmount(0.51).asString(in: .zil) == "0\(decSep)51")
        #expect(ZilAmount(0).asString(in: .zil) == "0")
        #expect(ZilAmount(1).asString(in: .zil) == "1")
        #expect(ZilAmount(9).asString(in: .zil) == "9")
    }

    @Test func smallLiAsLiString() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(Li(0.1).asString(in: .li) == "0\(decSep)1")
        #expect(Li(0.1).asString(in: .zil) == "0\(decSep)0000001")
        #expect(Li(0.49).asString(in: .li) == "0\(decSep)49")
        #expect(Li(0.5).asString(in: .li) == "0\(decSep)5")
        #expect(Li(0.51).asString(in: .li) == "0\(decSep)51")
        #expect(Li(0.51).asString(in: .zil) == "0\(decSep)00000051")
        #expect(Li(0).asString(in: .li) == "0")
        #expect(Li(1).asString(in: .li) == "1")
        #expect(Li(9).asString(in: .li) == "9")
    }

    @Test func maxZilAmountAsZilString() {
        #expect(ZilAmount(21_000_000_000).asString(in: .zil) == "21000000000")
    }

    @Test func tenLiInQaAsString() {
        #expect(Qa(10_000_000).asString(in: .li) == "10")
    }

    @Test func qaToLiManyDecimals() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(Qa(1).asString(in: .li) == "0\(decSep)000001")
    }

    @Test(arguments: QaCase.all)
    func qaAsString(_ c: QaCase) {
        #expect(c.qa.asString(in: c.unit) == c.expected)
    }

    @Test func thatFormattingUsesCorrectSeparator() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        let amountString = "0\(decSep)01"
        #expect(try Zil(zil: amountString).asString(in: .zil) == amountString)
    }

    @Test func decimalStringZilAmount() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(try Zil(zil: "0\(decSep)01").asString(in: .li) == "10000")
    }

    @Test func thatStringOnlyContainingDecimalSeparatorThrowsError() {
        #expect(throws: AmountError<Zil>.endsWithDecimalSeparator) {
            try Zil(zil: "\(Locale.current.decimalSeparatorForSure)")
        }
    }

    @Test func thatStringStartingWithDecimalSeparatorDefaultsToZero() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(try Zil(zil: "\(decSep)1") == Zil(zil: "0\(decSep)1"))
    }

    @Test func zilAsZilStringCanContainDecimals() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(try Zil(zil: "0\(decSep)1").asString(in: .zil, roundingIfNeeded: nil) == "0\(decSep)1")
        #expect(try Zil(zil: "0\(decSep)0000000123").asQa == Qa(12300))
    }

    @Test func zilWithManyDecimalsToLiString() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(
            try Zil(zil: "0\(decSep)0000000123").asString(in: .li, roundingIfNeeded: nil)
                == "0\(decSep)0123"
        )
    }

    @Test func small() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(try Qa(li: "0\(decSep)000015").asString(in: .qa, roundingIfNeeded: nil) == "15")
    }

    @Test func tooSmallQaFromLi() {
        #expect(throws: AmountError<Li>.tooManyDecimalPlaces) {
            try Qa(li: "0\(Locale.current.decimalSeparatorForSure)0000001")
        }
    }

    @Test func tooSmallQaFromLiWrongSeparator() {
        let wrongSep = Locale.current.decimalSeparatorForSure == "." ? "," : "."
        #expect(throws: AmountError<Qa>.containsNonDecimalStringCharacter(disallowedCharacter: wrongSep)) {
            try Qa(qa: "0\(wrongSep)0000001")
        }
    }

    @Test func smallQaFromLiString() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(try Qa(li: "0\(decSep)000001") == Qa(1))
    }

    @Test func tooSmallQaFromQaString() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(throws: AmountError<Qa>.tooManyDecimalPlaces) {
            try Qa(qa: "0\(decSep)1")
        }
    }

    @Test func untrimmedStringsNoTrimmingSpaces() {
        #expect(throws: Never.self) { try Zil(trimming: "1 0") }
    }

    @Test func zilAmountFromDecimalStringWithLeadingZeroNoThrow() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(throws: Never.self) { try Zil(trimming: "1\(decSep)01") }
    }

    @Test func zilAmountFromDecimalStringWithLeadingZeroToString() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        let zilString = "1\(decSep)01"
        #expect(try Zil(trimming: zilString).asString(in: .zil) == zilString)
    }

    @Test func notRemovingTrailingZero() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        let zilString = "1\(decSep)0"
        #expect(try Zil(trimming: zilString).asString(in: .zil, minFractionDigits: 1) == zilString)
    }

    @Test func goodAndBadDecSepThrowsDisallowedCharError() {
        let decSep = Locale.current.decimalSeparatorForSure
        let badSep = decSep == "." ? "," : "."
        #expect(throws: AmountError<Zil>.containsNonDecimalStringCharacter(disallowedCharacter: badSep)) {
            try Zil(zil: "1\(badSep)\(decSep)2")
        }
        #expect(throws: AmountError<Zil>.containsNonDecimalStringCharacter(disallowedCharacter: badSep)) {
            try Zil(zil: "1\(decSep)\(badSep)2")
        }
    }

    @Test(arguments: moreThanOneDecSepInputs)
    func moreThanOneDecimalSeparatorThrowsError(_ input: String) {
        #expect(throws: AmountError<Zil>.moreThanOneDecimalSeparator) {
            try Zil(zil: input)
        }
    }

    @Test func qaToZil() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(try Qa(qa: "1000000000").asZil == Zil(zil: "0\(decSep)001"))
    }

    @Test(arguments: endsWithDecSepZilInputs)
    func decimalStringEndingWithDecimalSeparatorThrowsErrorZil(_ input: String) {
        #expect(throws: AmountError<Zil>.endsWithDecimalSeparator) {
            try Zil(zil: input)
        }
    }

    @Test(arguments: endsWithDecSepZilAmountInputs)
    func decimalStringEndingWithDecimalSeparatorThrowsErrorZilAmount(_ input: String) {
        #expect(throws: AmountError<Zil>.endsWithDecimalSeparator) {
            try ZilAmount(zil: input)
        }
    }

    @Test(arguments: endsWithDecSepLiFromZilInputs)
    func decimalStringEndingWithDecimalSeparatorThrowsErrorLiFromZil(_ input: String) {
        #expect(throws: AmountError<Zil>.endsWithDecimalSeparator) {
            try Li(zil: input)
        }
    }

    @Test(arguments: endsWithDecSepLiInputs)
    func decimalStringEndingWithDecimalSeparatorThrowsErrorLi(_ input: String) {
        #expect(throws: AmountError<Li>.endsWithDecimalSeparator) {
            try Li(li: input)
        }
    }

    @Test func liAsString() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(Li(1).asString(in: .qa) == "1000000")
        #expect(Li(1).asString(in: .li) == "1")
        #expect(Li(1).asString(in: .zil) == "0\(decSep)000001")
    }

    @Test(arguments: LiCase.all)
    func liAsString(_ c: LiCase) {
        #expect(c.li.asString(in: c.unit) == c.expected)
    }

    @Test(arguments: ZilCase.all)
    func zilAsString(_ c: ZilCase) {
        #expect(c.zil.asString(in: c.unit) == c.expected)
    }
}

// MARK: - Parameterized input sets

private var moreThanOneDecSepInputs: [String] {
    let d = Locale.current.decimalSeparatorForSure
    return [
        "1\(d)\(d)2",
        "\(d)\(d)",
        "1\(d)\(d)\(d)2",
        "\(d)\(d)\(d)",
        "\(d)1\(d)2",
        "1\(d)2\(d)3",
        "\(d)1\(d)2\(d)",
        "\(d)000\(d)",
        "\(d)000\(d)0",
        "0\(d)000\(d)",
        "0\(d)000\(d)0",
    ]
}

private var endsWithDecSepZilInputs: [String] {
    let d = Locale.current.decimalSeparatorForSure
    return ["0\(d)", "1\(d)"]
}

private var endsWithDecSepZilAmountInputs: [String] {
    let d = Locale.current.decimalSeparatorForSure
    return ["0\(d)", "1\(d)"]
}

private var endsWithDecSepLiFromZilInputs: [String] {
    let d = Locale.current.decimalSeparatorForSure
    return ["0\(d)", "1\(d)"]
}

private var endsWithDecSepLiInputs: [String] {
    let d = Locale.current.decimalSeparatorForSure
    return ["0\(d)", "1\(d)"]
}
