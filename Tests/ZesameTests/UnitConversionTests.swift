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
import Testing
@testable import Zesame

@Suite struct UnitConversionTests {
    private let decSep = Locale.current.decimalSeparatorForSure

    @Test func zilToLi() {
        #expect(Zil(1).asLi == Li(1_000_000))
    }

    @Test func zilToQa() {
        #expect(Zil(1).asQa == Qa(1_000_000_000_000))
    }

    @Test func liToQa() {
        #expect(Li(1).asQa == Qa(1_000_000))
    }

    @Test func liFromQa() {
        #expect(Li(qa: 1_000_000) == 1)
    }

    @Test func zilEMinus5() {
        #expect(Zil.toQa(double: 0.000001) == 1_000_000)
        #expect(Zil(0.000001).qa == 1_000_000)
    }

    @Test func liToZil() {
        #expect(Li(1).asZil == Zil(0.000001))
    }

    @Test func zilFromLi() {
        #expect(Zil(li: 1_000_000) == 1)
    }

    @Test func zilFromQa() {
        #expect(Zil(qa: 1_000_000_000) == 0.001)
    }

    @Test func stringToZil() {
        #expect(Zil(1) == "1")
    }

    @Test func stringToLi() {
        #expect(Li(1) == "1")
    }

    @Test func stringToQa() {
        #expect(Qa(1) == "1")
    }

    @Test func compareZilAndLi() {
        #expect(Zil(1) > Li(2))
        #expect(Zil(1) > Li(999_999))
        #expect(Zil(1) < Li(9_999_990))
    }

    @Test func compareZilAndQa() {
        #expect(Zil(1) > Qa(2))
        #expect(Zil(1) > Qa(999_999_999_999))
        #expect(Zil(1) < Qa(9_999_999_999_990))
    }

    @Test func compareLiAndQa() {
        #expect(Li(1) > Qa(2))
        #expect(Li(1) > Qa(999_999))
        #expect(Li(1) < Qa(9_999_990))
    }

    @Test func additionOfDifferentUnits() {
        let zil: Zil = 2
        let li: Li = 600_007
        let qa: Qa = 500_002_000_123
        let amount = zil + qa + li
        #expect(amount.asQa == 3_100_009_000_123)
    }

    @Test func additionOfUpperboundOverflow() throws {
        let foo: ZilAmount = try ZilAmount.max - 1
        let bar: ZilAmount = 2
        #expect {
            try foo + bar
        } throws: { error in
            error is AmountError<ZilAmount>
        }
    }

    @Test func minGasPriceConversion() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(try Zil(zil: "0\(decSep)1") == Zil(qa: 100_000_000_000))
        #expect(try Zil(zil: "0\(decSep)1") == Zil(li: 100_000))
    }

    @Test func zilAmountLiteral() {
        let amount: ZilAmount = 15
        #expect(amount == 15)
    }

    @Test func gasPriceMinimum() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(GasPrice.min.asLi == 100_000)
        #expect(GasPrice.min.zilString == "0\(decSep)1")
    }

    @Test func zilAmountAndZil() {
        let foo: ZilAmount = 123
        let bar: Zil = 123
        #expect(foo == bar)
    }

    @Test func gasPriceAndQa() {
        let foo: GasPrice = 123_000_000_000
        let bar: Qa = 123_000_000_000
        #expect(foo == bar)
    }

    @Test func zilStringFromLi() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(Li(7_654_321).zilString == "7\(decSep)654321")
        #expect(Li(654_321).zilString == "0\(decSep)654321")
    }

    @Test func zilStringFromQa() {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(Qa(1).zilString == "0\(decSep)000000000001")
        #expect(Qa(123_456).zilString == "0\(decSep)000000123456")
    }

    @Test func liValue() {
        #expect(Li(0.01).qa == 10000)
    }

    @Test func conversionFromDecimalZilToLi() {
        #expect(Zil(0.1).qa == 100_000_000_000)
        #expect(Li(100_000).qa == 100_000_000_000)
    }

    @Test func smallDecimals() {
        #expect(Zil(0.000000000001).qa == 1)
    }

    @Test func conversionFromDecimalZilToQa() {
        #expect(Qa(Zil(0.000000000001)) == 1)
        #expect(Qa(Zil(10.000000000001)) == 10_000_000_000_001)
        #expect(Qa(Zil(10.000000000002)) > 10_000_000_000_001)
        #expect(Qa(Zil(9.000000000001)) < 10_000_000_000_001)

        #expect(Zil(0.000000000001).asQa == 1)
        #expect(Zil(10.000000000001).asQa == 10_000_000_000_001)
        #expect(Zil(10.000000000002).asQa > 10_000_000_000_001)
        #expect(Zil(9.000000000001).asQa < 10_000_000_000_001)
    }

    @Test func conversionFromDecimalLi() {
        #expect(Li(0.1).qa == 100_000)
    }

    @Test func tooSmallGasPrice() {
        #expect {
            let notALiteral = 999_000_000
            return try GasPrice(notALiteral)
        } throws: { error in
            guard let amountError = error as? AmountError<GasPrice>,
                  case let .tooSmall(min) = amountError else { return false }
            return min == GasPrice.min
        }
    }

    @Test func boundString() throws {
        let qaString = "18446744073637511711"
        #expect(
            try ZilAmount(zil: Zil(qa: Qa(trimming: qaString)))
                == ZilAmount(zil: Zil(qa: qaString))
        )
        #expect(
            try ZilAmount(zil: Zil(qa: qaString))
                == ZilAmount(qa: qaString)
        )
        let amount = try ZilAmount(qa: qaString)
        #expect(amount.qaString == "18446744073637511711")
    }

    @Test func unboundString() throws {
        let qaString = "18446744073637511711"
        let zil = try Zil(qa: qaString)
        #expect(zil.qaString == "18446744073637511711")
    }

    @Test func stringZilMaxAmount() {
        #expect(ZilAmount.max.zilString == "21000000000")
    }

    @Test func zilExceedingZilAmountMaxSinceZilIsUnbound() {
        #expect(ZilAmount.max.asZil + 1 == 21_000_000_001)
    }

    @Test func negativeAmountForZilSinceItIsUnbound() {
        let two: Zil = 2
        #expect(two.zilString == "2")
        #expect(two.liString == "2000000")
        let negOne: Zil = two - 3
        #expect(negOne == -1)
        #expect(two - 3 == -1)
    }

    @Test func zilStringInits() throws {
        #expect(try Zil(zil: "1") == 1)
        #expect(try Zil(zil: "1") < 2)
        #expect(try Zil(zil: "3") > 2)

        #expect(try Zil(li: "100000") == 0.1)
        #expect(try Zil(li: "100000") < 0.11)
        #expect(try Zil(li: "120000") > 0.11)

        #expect(try Zil(qa: "1000000000") == 0.001)
        #expect(try Zil(qa: "1000000000") < 0.0011)
        #expect(try Zil(qa: "2000000000") > 0.0019)
    }

    @Test func liStringInits() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(try Li(zil: "0\(decSep)01") == 10000)
        #expect(try Li(zil: "0\(decSep)01") < 100_000)
        #expect(try Li(zil: "0\(decSep)11") > 100_000)

        #expect(try Li(li: "5") == 5)
        #expect(try Li(li: "5") < 6)
        #expect(try Li(li: "5") > 4)

        #expect(try Li(qa: "1000") == 0.001)
        #expect(try Li(qa: "1000") < 0.0011)
        #expect(try Li(qa: "1000") > 0.0009)
    }

    @Test func qaStringInits() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        #expect(try Qa(zil: "1") == 1_000_000_000_000)
        #expect(try Qa(zil: "1") < 1_000_000_000_001)
        #expect(try Qa(zil: "1\(decSep)000000000001") > 1_000_000_000_000)

        #expect(try Qa(li: "1") == 1_000_000)
        #expect(try Qa(li: "1") < 1_000_001)
        #expect(try Qa(li: "2") > 1_999_999)

        #expect(try Qa(qa: "1") == 1)
        #expect(try Qa(qa: "1") < 2)
        #expect(try Qa(qa: "100") > 99)
        #expect(try Qa(qa: "100") < 101)
    }
}
