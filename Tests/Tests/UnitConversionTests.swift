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
        XCTAssertEqual(try! Zil(1).inLi, try! Li(1000000))
    }

    func testZilToQa() {
        XCTAssertEqual(try! Zil(1).inQa, try! Qa(1000000000000))
    }

    func testLiToQa() {
        XCTAssertEqual(try! Li(1).inQa, try! Qa(1000000))
    }

    func testLiFromQa() {
        XCTAssertEqual(try! Li(qa: 1000000), 1)
    }

    func testLiToZil() {
        XCTAssertEqual(try! Li(1).inZil, try! Zil(0.000001))
    }

    func testZilFromLi() {
        XCTAssertEqual(try! Zil(li: 1000000), 1)
    }

    func testZilFromQa() {
        XCTAssertEqual(try! Zil(qa: 1000000000), 0.001)
    }

    func testStringToZil() {
        XCTAssertEqual("1", try! Zil(1))
    }

    func testStringToLi() {
        XCTAssertEqual("1", try! Li(1))
    }

    func testStringToQa() {
        XCTAssertEqual("1", try! Qa(1))
    }
    func testCompareZilAndLi() {
        XCTAssertTrue(try! Zil(1) > Li(2))
        XCTAssertTrue(try! Zil(1) > Li(999999))
        XCTAssertTrue(try! Zil(1) < Li(9999990))
    }

    func testCompareZilAndQa() {
        XCTAssertTrue(try! Zil(1) > Qa(2))
        XCTAssertTrue(try! Zil(1) > Qa(999999999999))
        XCTAssertTrue(try! Zil(1) < Qa(9999999999990))
    }

    func testCompareLiAndQa() {
        XCTAssertTrue(try! Li(1) > Qa(2))
        XCTAssertTrue(try! Li(1) > Qa(999999))
        XCTAssertTrue(try! Li(1) < Qa(9999990))
    }
}
