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

    override func setUp() {
        GasPrice.restoreDefaultMax()
        XCTAssertEqual(GasPrice.maxMagnitude, GasPrice.maxMagnitudeDefault)
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

    func testDefaultMaxMagnitudeIs10Zil() {
        try! XCTAssertTrue(GasPrice.max == Zil(10))
    }

    func testDecreasingMaxPrice() {
        XCTAssertEqual(GasPrice.maxMagnitude, GasPrice.maxMagnitudeDefault)
        let newMaxMagnitude: GasPrice.Magnitude = (GasPrice.min.inLi + 1.li).inQa.magnitude
        GasPrice.maxMagnitude = newMaxMagnitude
        XCTAssertEqual(GasPrice.maxMagnitude, 1_001_000_000)

        var didThrowError = false
        do {
            let _ = try GasPrice(li: 1002)
        } catch let error as AmountError<GasPrice>  {
            didThrowError = true
            switch error {
            case .tooLarge(let max):
                XCTAssertEqual(max.magnitude, newMaxMagnitude)
            default: XCTFail()
            }
        } catch {
            return XCTFail()
        }
        XCTAssertTrue(didThrowError)
    }

    func testIncreasingMaxGasPrice() {
        XCTAssertEqual(GasPrice.maxMagnitude, GasPrice.maxMagnitudeDefault)
        let newMaxMagnitude: GasPrice.Magnitude = try! Zil(1337).inQa.magnitude
        GasPrice.maxMagnitude = newMaxMagnitude
        XCTAssertEqual(GasPrice.maxMagnitude, 1_337_000_000_000_000)


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
                XCTAssertEqual(max.magnitude, newMaxMagnitude)
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
