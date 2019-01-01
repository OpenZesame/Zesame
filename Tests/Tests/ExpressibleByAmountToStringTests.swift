//
//  File.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-01.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation
import XCTest
import BigInt
@testable import Zesame

class ExpressibleByAmountToStringTests: XCTestCase {

    func testTestNotLotsOfNines() {
        XCTAssertEqual(Qa(10).asString(in: .zil), "0.00000000001")
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
        XCTAssertEqual(Qa(1000).asString(in: .zil), "0.000000001")

        XCTAssertEqual(Qa(10000).asString(in: .qa), "10000")
        XCTAssertEqual(Qa(10000).asString(in: .li), "0.01")
        XCTAssertEqual(Qa(10000).asString(in: .zil), "0.00000001")

        XCTAssertEqual(Qa(100000).asString(in: .qa), "100000")
        XCTAssertEqual(Qa(100000).asString(in: .li), "0.1")
        XCTAssertEqual(Qa(100000).asString(in: .zil), "0.0000001")

        XCTAssertEqual(Qa(1000000).asString(in: .qa), "1000000")
        XCTAssertEqual(Qa(1000000).asString(in: .li), "1")
        XCTAssertEqual(Qa(1000000).asString(in: .zil), "0.000001")

        XCTAssertEqual(Qa(10000000).asString(in: .qa), "10000000")
        XCTAssertEqual(Qa(10000000).asString(in: .li), "10")
        XCTAssertEqual(Qa(10000000).asString(in: .zil), "0.00001")

        XCTAssertEqual(Qa(100000000).asString(in: .qa), "100000000")
        XCTAssertEqual(Qa(100000000).asString(in: .li), "100")
        XCTAssertEqual(Qa(100000000).asString(in: .zil), "0.0001")

        XCTAssertEqual(Qa(1000000000).asString(in: .qa), "1000000000")
        XCTAssertEqual(Qa(1000000000).asString(in: .li), "1000")
        XCTAssertEqual(Qa(1000000000).asString(in: .zil), "0.001")

        XCTAssertEqual(Qa(10000000000).asString(in: .qa), "10000000000")
        XCTAssertEqual(Qa(10000000000).asString(in: .li), "10000")
        XCTAssertEqual(Qa(10000000000).asString(in: .zil), "0.01")

        XCTAssertEqual(Qa(100000000000).asString(in: .qa), "100000000000")
        XCTAssertEqual(Qa(100000000000).asString(in: .li), "100000")
        XCTAssertEqual(Qa(100000000000).asString(in: .zil), "0.1")

        XCTAssertEqual(Qa(1000000000000).asString(in: .qa), "1000000000000")
        XCTAssertEqual(Qa(1000000000000).asString(in: .li), "1000000")
        XCTAssertEqual(Qa(1000000000000).asString(in: .zil), "1")

        XCTAssertEqual(Qa(10000000000000).asString(in: .qa), "10000000000000")
        XCTAssertEqual(Qa(10000000000000).asString(in: .li), "10000000")
        XCTAssertEqual(Qa(10000000000000).asString(in: .zil), "10")
    }
}
