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

class TransactionCostTests: XCTestCase {

    func testTotalAmount() {

        let amount: Amount = 21_000_000_000
        XCTAssertEqual(amount.qa, "21000000000000000000000")
    }

    func testGasPrice() {
        let gasPrice: GasPrice = 1_100_000_000_000
        XCTAssertEqual(gasPrice.asZil, 1.1)
    }

    func testWorking() {
        XCTAssertEqual(Zil(10).qa, BigInt(10_000_000_000_000))
    }

    func testExceedingTotalSupplyIntegerLiteral() {
        var didThrowError = false
        do {
            let _ = try Payment.estimatedTotalCostOfTransaction(amount: 20_999_999_999, gasPrice: 1_000_000_000_001)
        } catch let error as AmountError<Amount>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, Amount.max)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }

    func testExceedingTotalSupplyStringLiteral() {
        var didThrowError = false
        do {
            let _ = try Payment.estimatedTotalCostOfTransaction(amount: "20999999999", gasPrice: "1000000000001")
        } catch let error as AmountError<Amount>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, Amount.max)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }
}
