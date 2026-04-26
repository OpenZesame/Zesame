//
// MIT License
//
// Copyright (c) 2018-2026 Open Zesame (https://github.com/OpenZesame)
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

import BigInt
import Foundation

/// Gas price (per gas unit) for a Zilliqa transaction. Stored in Qa, the smallest unit.
///
/// `GasPrice` carries adjustable lower/upper bounds so that the locally-known minimum can be
/// refreshed from the network (see ``DefaultZilliqaService/getMinimumGasPrice(alsoUpdateLocallyCachedMinimum:)``)
/// without re-deploying the library.
public struct GasPrice: ExpressibleByAmount, AdjustableUpperbound, AdjustableLowerbound {
    /// The underlying unsigned big-integer magnitude.
    public typealias Magnitude = Qa.Magnitude
    /// Canonical unit for this type — Qa.
    public static let unit: Unit = .qa

    /// The price in Qa.
    public let qa: Magnitude

    /// By default we set gasPrice of 0.1 Zil (= 100_000 Li = 100_000_000_000 Qa), preparing for
    /// ZIP-18 https://github.com/jsarcher/ZIP/blob/master/zips/zip-18.md
    ///
    /// But you SHOULD call `ZilliqaService.getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: true)`
    /// which will update this.
    ///
    public static let minInQaDefault: Magnitude = 100_000_000_000
    /// Active minimum gas price (in Qa). Updates here propagate to validation across new
    /// ``GasPrice`` values. Setting it above ``maxInQa`` traps.
    public static var minInQa = minInQaDefault {
        willSet {
            guard newValue <= maxInQa else {
                fatalError(
                    "Cannot set minInQa to greater than maxInQa, max: \(maxInQa), new min: \(newValue) (old: \(minInQa)"
                )
            }
        }
    }

    /// By default GasPrice has an upperbound of 100 Zil, this can be changed.
    public static let maxInQaDefault: Magnitude = 100_000_000_000_000
    /// Active maximum gas price (in Qa). Setting it below ``minInQa`` traps.
    public static var maxInQa = maxInQaDefault {
        willSet {
            guard newValue >= minInQa else {
                fatalError(
                    "Cannot set maxInQa to less than minInQa, min: \(minInQa), new max: \(newValue) (old: \(maxInQa)"
                )
            }
        }
    }

    /// Creates a `GasPrice` after validating that `qa` lies within ``minInQa``…``maxInQa``.
    public init(qa: Magnitude) throws {
        self.qa = try GasPrice.validate(value: qa)
    }
}
