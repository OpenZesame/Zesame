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
        XCTAssertEqual(GasPrice.max.asZil, 10)
        XCTAssertEqual(GasPrice.max.qa, 10_000_000_000_000)
    }

    func testMinGasPriceIs1000Li() {
        XCTAssertEqual(GasPrice.min.qa, Li(1000).qa)
        XCTAssertEqual(GasPrice.min.liString, "1000")
        XCTAssertEqual(GasPrice.min.asLi, 1000)
        XCTAssertEqual(GasPrice.min.qa, 1_000_000_000)
    }

    func testMaxGasPrice() {
        do {
            let tenZil = try GasPrice(zil: 10)
            XCTAssertEqual(tenZil.asLi, 10_000_000)
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
        let newMaxInQa: GasPrice.Magnitude = (GasPrice.min.asLi + 1.li).qa
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
            XCTAssertEqual(tenZil.asLi, 1_336_000_000)
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
