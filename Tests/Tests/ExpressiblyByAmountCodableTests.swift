//
//  ExpressiblyByAmountCodableTests.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-31.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import Foundation
import XCTest

@testable import Zesame

class ExpressiblyByAmountCodableTests: XCTestCase {

    func testValidJSON() {
        do {
            let response = try JSONDecoder().decode(BalanceResponse.self, from: validJSON)
            XCTAssertEqual(response.nonce, 16)
            XCTAssertEqual(response.balance, "18446744073637511711")
        } catch {
            XCTFail("JSONDecoding should not fail, got error: \(error)")
        }
    }
}

private let validJSON = """
{
    "amount" : "237",
    "recipient" : "F510333720c5dD3c3c08bC8e085E8C981CE74691"
}
""".data(using: .utf8)!
