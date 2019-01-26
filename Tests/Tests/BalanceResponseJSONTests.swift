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
