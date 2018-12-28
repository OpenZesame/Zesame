//
//  TransactionCostTests.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-16.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import XCTest

@testable import Zesame

class TransactionCostTests: XCTestCase {

    func testTotalAmount() {

        let amount: ZilAmount = 21_000_000_000
        XCTAssertEqual(amount.magnitude, 21_000_000_000)
        XCTAssertEqual(amount.magnitude, amount.inZil.magnitude)
        XCTAssertEqual(Zil.max.magnitude, Zil.maxMagnitude)
        XCTAssertEqual(Zil.max.magnitude, amount.inZil.magnitude)
        XCTAssertEqual(Zil.max, amount.inZil)
    }

    func testGasPrice() {
        let gasPrice: GasPrice = 1_100_000_000_000
        XCTAssertEqual(gasPrice.inZil, 1.1)
    }

    func testExceedingTotalSupplyIntegerLiteral() {
        var didThrowError = false
        do {
            let _ = try Payment.estimatedTotalCostOfTransaction(amount: 20_999_999_999, gasPrice: 1_000_000_000_001)
        } catch let error as AmountError  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, Zil.maxMagnitude)
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
        } catch let error as AmountError  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, Zil.maxMagnitude)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }
}
