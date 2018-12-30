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
}
