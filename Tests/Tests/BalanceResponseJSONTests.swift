//
//  BalanceResponseJSONTests.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-30.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import BigInt
import XCTest

@testable import Zesame

class BalanceResponseJSONTests: XCTestCase {

    func testDecoding() {
        do {
            let response = try JSONDecoder().decode(BalanceResponse.self, from: validJSON.data(using: .utf8)!)
            XCTAssertEqual(response.nonce, 16)
            XCTAssertEqual(response.balance.qaString, "18446744073637511711")
            XCTAssertNotEqual(response.balance.qaString, "18446744073637511712")
            XCTAssertNotEqual(response.balance.qaString, "18446744073637511710")
        } catch {
            XCTFail("JSONDecoding should not fail, got error: \(error)")
        }
    }

    func testEncoding() {
        do {
            let model = BalanceResponse(balance: try ZilAmount(qa: "18446744073637511711"), nonce: 16)
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let json = try jsonEncoder.encode(model)
            let jsonString = String(data: json, encoding: .utf8)!
            XCTAssertEqual(jsonString, jsonString)
        } catch {
            XCTFail("JSONEncoding should not fail, got error: \(error)")
        }
    }
}

private let validJSON = """
{
"balance" : "18446744073637511711",
"nonce" : 16
}
"""
