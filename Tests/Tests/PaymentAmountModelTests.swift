//
//  PaymentAmountModelTests.swift
//  ZilliqaSDKTests
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//


import XCTest
@testable import ZilliqaSDK

class PaymentAmountModelTests: XCTestCase {

    func testCreatingValidPaymentAmountUsingDesignatedInitializer() {
        let amount = Payment.Amount(double: 1)
        XCTAssertTrue(amount?.amount == 1)
    }

    func testCreatingValidPaymentAmountUsingExpressibleByFloatLiteralInitializer() {
        let amount: Payment.Amount = 1.0
        XCTAssertTrue(amount.amount == 1)
    }

    func testCreatingValidPaymentAmountUsingExpressibleByIntegerLiteralInitializer() {
        let amount: Payment.Amount = 1
        XCTAssertTrue(amount.amount == 1)
    }
}
