//
//  GasPriceTests.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-30.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import XCTest

@testable import Zesame

class GasPriceTests: XCTestCase {

    private func restoreBounds() {
        GasPrice.restoreDefaultBounds()
        XCTAssertEqual(GasPrice.maxInQa, GasPrice.maxInQaDefault)
        XCTAssertEqual(GasPrice.minInQa, GasPrice.minInQaDefault)
    }

    override func setUp() {
        restoreBounds()
    }

    override func tearDown() {
        restoreBounds()
    }

    func testMaxGasPriceIs10Zil() {
        XCTAssertEqual(GasPrice.max.qa, Zil(10).qa)
        XCTAssertEqual(GasPrice.max.inZil, 10)
        XCTAssertEqual(GasPrice.max.qa, 10_000_000_000_000)
    }

    func testMinGasPriceIs1000Li() {
        XCTAssertEqual(GasPrice.min.qa, Li(1000).qa)
        XCTAssertEqual(GasPrice.min.liString, "1000")
        XCTAssertEqual(GasPrice.min.inLi, 1000)
        XCTAssertEqual(GasPrice.min.qa, 1_000_000_000)
    }

    func testMaxGasPrice() {
        do {
            let tenZil = try GasPrice(zil: 10)
            XCTAssertEqual(tenZil.inLi, 10_000_000)
        } catch {
            return XCTFail()
        }
    }

    func testExceedingMaxGasPriceThrowsError() {
        var didThrowError = false
        do {
             let _ = try GasPrice.init(zil: 11)
        } catch let error as AmountError<GasPrice>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, GasPrice.max)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }

    func testDefaultMaxMagnitudeIs10Zil() {
        XCTAssertEqual(GasPrice.maxInQaDefault, GasPrice.maxInQa)
        XCTAssertEqual(GasPrice.max.zilString, "10")
    }

    func testDecreasingMaxPrice() {
        let newMaxInQa: GasPrice.Magnitude = (GasPrice.min.inLi + 1.li).qa
        GasPrice.maxInQa = newMaxInQa
        XCTAssertEqual(GasPrice.maxInQa, 1_001_000_000)

        var didThrowError = false
        do {
            let _ = try GasPrice(li: 1002)
        } catch let error as AmountError<GasPrice>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max.qa, newMaxInQa)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }

    func testIncreasingMaxGasPrice() {
        let newMaxInqa: GasPrice.Magnitude = Zil(1337).qa
        GasPrice.maxInQa = newMaxInqa
        XCTAssertEqual(GasPrice.maxInQa, 1_337_000_000_000_000)

        do {
            let tenZil = try GasPrice(zil: 1336)
            XCTAssertEqual(tenZil.inLi, 1_336_000_000)
        } catch {
            return XCTFail()
        }

        var didThrowError = false
        do {
            let _ = try GasPrice(zil: 1338)
        } catch let error as AmountError<GasPrice>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max.qa, newMaxInqa)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }

    func testIncreasedMaxGasPrice() {
        var didThrowError = false
        do {
            let _ = try GasPrice(zil: 11)
        } catch let error as AmountError<GasPrice>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max, GasPrice.max)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }
}
