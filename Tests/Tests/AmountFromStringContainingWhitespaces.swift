//
//  AmountFromStringContainingWhitespaces.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-02.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation
import XCTest

@testable import Zesame

class AmountFromStringContainingWhitespaces: XCTestCase {


    func testZilStringContainingWhitespaces() {
        XCTAssertEqual(try Zil("1 234 567").qa, 1_234_567_000_000_000_000)
    }

    func testZilAmountContainingWhitespaces() {
        XCTAssertEqual(try ZilAmount("1 234 567").qa, 1_234_567_000_000_000_000)
    }

    func testGasPriceContainingWhitespaces() {
        XCTAssertEqual(try GasPrice(li: "1 567").qa, 1_567_000_000)
    }
}
