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
import Testing
@testable import Zesame

/// Serialized because tests mutate global GasPrice bounds.
@Suite(.serialized) final class GasPriceTests {
    init() {
        GasPrice.restoreDefaultBounds()
    }

    deinit { GasPrice.restoreDefaultBounds() }

    @Test func maxGasPriceIs100Zil() {
        #expect(GasPrice.max.qa == Zil(100).qa)
        #expect(GasPrice.max.asZil == 100)
        #expect(GasPrice.max.qa == 100_000_000_000_000)
    }

    @Test func minGasPriceIs100_000Li() {
        #expect(GasPrice.min.qa == Li(100_000).qa)
        #expect(GasPrice.min.liString == "100000")
        #expect(GasPrice.min.asLi == 100_000)
        #expect(GasPrice.min.qa == 100_000_000_000)
    }

    @Test func maxGasPrice() throws {
        let tenZil = try GasPrice(zil: 100)
        #expect(tenZil.asLi == 100_000_000)
    }

    @Test func exceedingMaxGasPriceThrowsError() {
        #expect {
            try GasPrice(zil: 101)
        } throws: { error in
            guard let amountError = error as? AmountError<GasPrice>,
                  case let .tooLarge(max) = amountError else { return false }
            return max == GasPrice.max
        }
    }

    @Test func defaultMaxMagnitudeIs100Zil() {
        #expect(GasPrice.maxInQaDefault == GasPrice.maxInQa)
        #expect(GasPrice.max.zilString == "100")
    }

    @Test func decreasingMaxPrice() throws {
        let newMaxInQa: GasPrice.Magnitude = (GasPrice.min.asLi + 1.li).qa
        GasPrice.maxInQa = newMaxInQa
        #expect(GasPrice.maxInQa == 100_001_000_000)

        #expect {
            try GasPrice(li: 100_000_002)
        } throws: { error in
            guard let amountError = error as? AmountError<GasPrice>,
                  case let .tooLarge(max) = amountError else { return false }
            return max.qa == newMaxInQa
        }
    }

    @Test func increasingMaxGasPrice() throws {
        let newMaxInQa: GasPrice.Magnitude = Zil(1337).qa
        GasPrice.maxInQa = newMaxInQa
        #expect(GasPrice.maxInQa == 1_337_000_000_000_000)

        let price = try GasPrice(zil: 1336)
        #expect(price.asLi == 1_336_000_000)

        #expect {
            try GasPrice(zil: 1338)
        } throws: { error in
            guard let amountError = error as? AmountError<GasPrice>,
                  case let .tooLarge(max) = amountError else { return false }
            return max.qa == newMaxInQa
        }
    }

    @Test func increasedMaxGasPriceStillEnforcesDefault() {
        #expect {
            try GasPrice(zil: 101)
        } throws: { error in
            guard let amountError = error as? AmountError<GasPrice>,
                  case let .tooLarge(max) = amountError else { return false }
            return max == GasPrice.max
        }
    }
}
