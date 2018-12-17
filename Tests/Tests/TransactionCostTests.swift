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

    func testDefaultGasLimitEquals1() {
        guard
            let manual = try? Payment.estimatedTotalTransactionFee(gasPrice: 100, gasLimit: 1),
            let defaultLimit = try? Payment.estimatedTotalTransactionFee(gasPrice: 100)
            else {
                return XCTFail()
        }
        XCTAssertEqual(defaultLimit, manual)
    }

    func testPrice100EqualsAmount1EMinus10() {
        guard let cost = try? Payment.estimatedTotalTransactionFee(gasPrice: 100) else {
            return XCTFail()
        }
        let expected: Double = pow(10, -10)
        XCTAssertEqual(cost.value, expected)
    }

    func testPrice100AndLimit10EqualsEMinus9() {
        guard let cost = try? Payment.estimatedTotalTransactionFee(gasPrice: 100, gasLimit: 10) else {
            return XCTFail()
        }
        let expected: Double = pow(10, -9)
        XCTAssertEqual(cost.value, expected)
    }

    func testNonDecimalValuesIntegerLiteral() {
        // The 9,999th and the 10,000th prime
        guard let cost = try? Payment.estimatedTotalTransactionFee(gasPrice: 104723, gasLimit: 104729) else {
            return XCTFail()
        }
        XCTAssertEqual(cost.value, 0.010967535067)
    }

    func testGasPriceValueForTransaction() {
        let price: GasPrice = 1_000_000_000
        XCTAssertEqual(price.asAmount(), "0.001")
        XCTAssertEqual(price.valueForTransaction, 1_000_000_000)
    }

    func testAmountToGasPriceValueForTransaction() {
        let amount: Amount = 1
        let price = amount.asGasPrice()
        XCTAssertEqual(price.significand, 1_000_000_000_000)
        XCTAssertEqual(price.value, 1)
        XCTAssertEqual(price.valueForTransaction, 1_000_000_000_000)
    }

    func testNonDecimalValuesStringLiteral() {
        // The 9,999th and the 10,000th prime
        guard let cost = try? Payment.estimatedTotalTransactionFee(gasPrice: "104723", gasLimit: "104729") else {
            return XCTFail()
        }
        XCTAssertEqual(cost, "0.010967535067")
        XCTAssertEqual(cost.valueForTransaction, 0)
    }

    func testOverOneIntegerLiteral() {
        guard let cost = try? Payment.estimatedTotalTransactionFee(gasPrice: 1_000_001, gasLimit: 1_000_000) else {
            return XCTFail()
        }
        XCTAssertGreaterThan(cost.value, 1.0)
    }

    func testOverOneStringLiteral() {
        guard let cost = try? Payment.estimatedTotalTransactionFee(gasPrice: "1000001", gasLimit: "1000000") else {
            return XCTFail()
        }
        XCTAssertGreaterThan(cost.value, 1.0)
        XCTAssertGreaterThan(cost, "1")
        XCTAssertGreaterThan(cost, "1.0")
    }

    func testCostOfTransactionDedicatedTypes() {
        do {
            let amount = try Amount(significand: 9)
            let gasPrice = try GasPrice(significand: 1_000_000_000_000)
            let cost = try Payment.estimatedTotalCostOfTransaction(amount: amount, gasPrice: gasPrice)
            XCTAssertEqual(cost.value, 10)
            XCTAssertEqual(cost.value, 10.0)
            XCTAssertEqual(cost, "10")
            XCTAssertEqual(cost, "10.0")
        } catch {
            return XCTFail()
        }
    }

    func testCostOfTransactionIntegerLiteral() {
        guard let cost = try? Payment.estimatedTotalCostOfTransaction(amount: 9, gasPrice: 1_000_000_000_000) else {
            return XCTFail()
        }
        XCTAssertEqual(cost.value, 10)
    }

    func testCostOfTransactionStringLiteral() {
        guard let cost = try? Payment.estimatedTotalCostOfTransaction(amount: "9", gasPrice: "1000000000000") else {
            return XCTFail()
        }
        XCTAssertEqual(cost.value, 10)
        XCTAssertEqual(cost.value, 10.0)
        XCTAssertEqual(cost, "10")
        XCTAssertEqual(cost, "10.0")
    }

    func testEqualsTotalSupplyDedicatedType() {
        do {
            let amount = try Amount(significand: 20_999_999_999)
            let gasPrice = try GasPrice(significand: 1_000_000)
            let gasLimit = try Amount(significand: 1_000_000)
            let cost = try Payment.estimatedTotalCostOfTransaction(amount: amount, gasPrice: gasPrice, gasLimit: gasLimit)
            XCTAssertEqual(cost.value, Amount.totalSupply)
        } catch {
            return XCTFail()
        }
    }

    func testEqualsTotalSupplyIntegerLiteral() {
        guard let cost = try? Payment.estimatedTotalCostOfTransaction(amount: 20_999_999_999, gasPrice: 1_000_000, gasLimit: 1_000_000) else {
            return XCTFail()
        }
        XCTAssertEqual(cost.value, Amount.totalSupply)
    }

    func testEqualsTotalSupplyStringLiteral() {
        guard let cost = try? Payment.estimatedTotalCostOfTransaction(amount: "20999999999", gasPrice: "1000000", gasLimit: "1000000") else {
            return XCTFail()
        }
        XCTAssertEqual(cost.value, Amount.totalSupply)
    }

    func testExceedingTotalSupplyDedicatedTypes() {
        var didThrowError = false
        do {
            let amount = try Amount(significand: 20_999_999_999)
            let gasPrice = try GasPrice(significand: 1_000_001)
            let gasLimit = try Amount(significand: 1_000_000)
            let _ = try Payment.estimatedTotalCostOfTransaction(amount: amount, gasPrice: gasPrice, gasLimit: gasLimit)
        } catch let error as AmountError  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, Amount.totalSupply)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }

    func testExceedingTotalSupplyIntegerLiteral() {
        var didThrowError = false
        do {
            let _ = try Payment.estimatedTotalCostOfTransaction(amount: 20_999_999_999, gasPrice: 1_000_001, gasLimit: 1_000_000)
        } catch let error as AmountError  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, Amount.totalSupply)
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
            let _ = try Payment.estimatedTotalCostOfTransaction(amount: "20999999999", gasPrice: "1000001", gasLimit: "1000000")
        } catch let error as AmountError  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, Amount.totalSupply)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }
}
