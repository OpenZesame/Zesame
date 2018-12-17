//
//  GasPriceAmountConversionTests.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-15.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import XCTest

@testable import Zesame


class GasPriceAmountConversionTests: XCTestCase {

    func testGasToAmount() {
        guard let gasPrice = try? GasPrice(significand: Amount.totalSupply / GasPrice.powerFactor) else {
            return XCTFail()
        }

        let asAmount = gasPrice.asAmount()
        XCTAssertEqual(asAmount.value, Amount.totalSupply)
    }

    func testGasPriceTo1Zil() {
        let gasPrice: GasPrice = 1_000_000_000_000
        XCTAssertEqual(gasPrice.significand, 1_000_000_000_000)
        XCTAssertEqual(gasPrice.value, 1.0)
        let asAmount = gasPrice.asAmount()
        XCTAssertEqual(asAmount.value, 1.0)
    }

    func testAmount1ZilToGasPrice() {
        let amount: Amount = 1
        let asGasPrice = amount.asGasPrice()
        XCTAssertEqual(asGasPrice.significand, 1_000_000_000_000)
        XCTAssertEqual(asGasPrice.value, 1)
    }

}
