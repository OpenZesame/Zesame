//
//  UnitConversionTests.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-15.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import XCTest

@testable import Zesame

class UnitConversionTests: XCTestCase {

    func testZilToLi() {
        XCTAssertEqual(Zil(1).inLi, Li(1000000))
    }

    func testZilToQa() {
        XCTAssertEqual(Zil(1).inQa, Qa(1000000000000))
    }

    func testLiToQa() {
        XCTAssertEqual(Li(1).inQa, Qa(1000000))
    }

    func testLiFromQa() {
        XCTAssertEqual(Li(qa: 1000000), 1)
    }

    func testLiToZil() {
        XCTAssertEqual(Li(1).inZil, Zil(0.000001))
    }

    func testZilFromLi() {
        XCTAssertEqual(Zil(li: 1000000), 1)
    }

    func testZilFromQa() {
        XCTAssertEqual(Zil(qa: 1000000000), 0.001)
    }

    func testStringToZil() {
        XCTAssertEqual("1", Zil(1))
    }

    func testStringToLi() {
        XCTAssertEqual("1", Li(1))
    }

    func testStringToQa() {
        XCTAssertEqual("1", Qa(1))
    }
    func testCompareZilAndLi() {
        XCTAssertTrue(Zil(1) > Li(2))
        XCTAssertTrue(Zil(1) > Li(999999))
        XCTAssertTrue(Zil(1) < Li(9999990))
    }

    func testCompareZilAndQa() {
        XCTAssertTrue(Zil(1) > Qa(2))
        XCTAssertTrue(Zil(1) > Qa(999999999999))
        XCTAssertTrue(Zil(1) < Qa(9999999999990))
    }

    func testCompareLiAndQa() {
        XCTAssertTrue(Li(1) > Qa(2))
        XCTAssertTrue(Li(1) > Qa(999999))
        XCTAssertTrue(Li(1) < Qa(9999990))
    }

    func testAdditionOfDifferentUnits() {
        let zil: Zil = 2
        let li: Li = 600_007
        let qa: Qa = 500_002_000_123
        let amount = zil + qa + li
        XCTAssertEqual(amount.inQa, 3_100_009_000_123)
    }

    func testAdditionOfUpperboundOverflow() {
        let foo: ZilAmount = try! ZilAmount.max - 1
        let bar: ZilAmount = 2
        var didThrowError = false

        do {
            let sum = try foo + bar
            XCTFail("Fail, should have thrown error, sum was: \(sum)")
        } catch let error as AmountError<ZilAmount>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, 21_000_000_000)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }

    func testZilAmountLiteral() {
        let amount: ZilAmount = 15
        XCTAssertEqual(amount, 15)
    }

    func testGasPriceMinimum() {
        XCTAssertEqual(GasPrice.min.inLi, 1000)
        XCTAssertEqual(GasPrice.minInLiAsInt, Int(GasPrice.min.inLi.magnitude))
    }

    func testZilAmountAndZil() {
        let foo: ZilAmount = 123
        let bar: Zil = 123
        XCTAssertTrue(foo == bar)
    }

    func testGasPriceAndQa() {
        let foo: GasPrice = 123_000_000_000
        let bar: Qa = 123_000_000_000
        XCTAssertTrue(foo == bar)
    }

    func testTooSmallGasPrice() {
        var didThrowError = false
        do {
            let _ = try GasPrice(999_000_000)
        } catch let error as AmountError<GasPrice>  {
            didThrowError = true
            switch error {
            case .tooSmall(let min):
                XCTAssertEqual(min, GasPrice.min)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }

    func testBoundString() {
        let qaString = "18446744073637511711"
        XCTAssertEqual(
            try ZilAmount(zil: Zil(qa: try Qa(magnitude: qaString))),
            try ZilAmount(zil: try Zil(qa: qaString))
        )
        XCTAssertEqual(
            try ZilAmount(zil: try Zil(qa: qaString)),
            try ZilAmount(qa: qaString)
        )
        do {
            let amount = try ZilAmount(qa: qaString)
            XCTAssertEqual(amount.inQa.magnitude, 18446744073637511711)
        } catch {
            XCTFail()
        }
    }

    func testUnboundString() {
        let qaString = "18446744073637511711"
        do {
            let zil = try Zil(qa: qaString)
            XCTAssertEqual(zil.inQa.magnitude, 18446744073637511711)
        } catch {
            XCTFail()
        }
    }

    func testZilExceedingZilAmountMaxSinceZilIsUnbound() {
        XCTAssertEqual((ZilAmount.max.inZil + 1).magnitude, 21_000_000_001)
    }

    func testNegativeAmountForZilSinceItIsUnbound() {
        let two: Zil = 2
        XCTAssertEqual(two.inLi.magnitude, 2_000_000)
        XCTAssertEqual(two.inLi, 2_000_000)
        let negOne: Zil = two - 3
        XCTAssertEqual(negOne, -1)
        // test literal
        XCTAssertEqual(two - 3, -1)
    }

    func testZilStringInits() {
        XCTAssertEqual(try Zil(zil: "1"), 1)
        XCTAssertLessThan(try Zil(zil: "1"), 2)
        XCTAssertGreaterThan(try Zil(zil: "3"), 2)

        XCTAssertEqual(try Zil(li: "100000"), 0.1)
        XCTAssertLessThan(try Zil(li: "100000"), 0.11)
        XCTAssertGreaterThan(try Zil(li: "120000"), 0.11)

        XCTAssertEqual(try Zil(qa: "1000000000"), 0.001)
        XCTAssertLessThan(try Zil(qa: "1000000000"), 0.0011)
        XCTAssertGreaterThan(try Zil(qa: "2000000000"), 0.0019)
    }

    func testLiStringInits() {
        XCTAssertEqual(try Li(zil: "0.01"), 10000)
        XCTAssertLessThan(try Li(zil: "0.01"), 100000)
        XCTAssertGreaterThan(try Li(zil: "0.11"), 100000)

        XCTAssertEqual(try Li(li: "5"), 5)
        XCTAssertLessThan(try Li(li: "5"), 6)
        XCTAssertGreaterThan(try Li(li: "5"), 4)

        XCTAssertEqual(try Li(qa: "1000"), 0.001)
        XCTAssertLessThan(try Li(qa: "1000"), 0.0011)
        XCTAssertGreaterThan(try Li(qa: "1000"), 0.0009)
    }

    func testQaStringInits() {
        XCTAssertEqual(try Qa(zil: "1"), 1_000_000_000_000)
        XCTAssertLessThan(try Qa(zil: "1"), 1_000_000_000_001)
        XCTAssertGreaterThan(try Qa(zil: "1.000000000001"), 1_000_000_000_000)

        XCTAssertEqual(try Qa(li: "1"), 1_000_000)
        XCTAssertLessThan(try Qa(li: "1"), 1_000_001)
        XCTAssertGreaterThan(try Qa(li: "2"), 1_999_999)

        XCTAssertEqual(try Qa(qa: "1"), 1)
        XCTAssertLessThan(try Qa(qa: "1"), 2)
        XCTAssertGreaterThan(try Qa(qa: "100"), 99)
        XCTAssertLessThan(try Qa(qa: "100"), 101)

    }
}
