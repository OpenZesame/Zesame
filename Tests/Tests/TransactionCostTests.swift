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

class TransactionCostTests: XCTestCase {

    func testTotalAmount() {

        let amount: ZilAmount = 21_000_000_000
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
        } catch let error as AmountError<ZilAmount>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, ZilAmount.max)
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
        } catch let error as AmountError<ZilAmount>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, ZilAmount.max)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }
}
