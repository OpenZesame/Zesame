//
//  BalanceResponseJSONTests.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-30.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

/// Example JSON from API docs: https://apidocs.zilliqa.com/#getbalance
private let validJSON = """
{
    "balance":"18446744073637511711",
    "nonce":16
}
""".data(using: .utf8)!

import Foundation
import XCTest

@testable import Zesame

class BalanceResponseJSONTests: XCTestCase {

    func testValidJSON() {
        do {
            let response = try JSONDecoder().decode(BalanceResponse.self, from: validJSON)
            XCTAssertEqual(response.nonce, 16)
            XCTAssertEqual(response.balance.inQa.magnitude, 18446744073637511711)
        } catch {
            XCTFail("JSONDecoding should not fail, got error: \(error)")
        }
    }
}
