//
// Copyright 2019 Open Zesame
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under thexc License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
