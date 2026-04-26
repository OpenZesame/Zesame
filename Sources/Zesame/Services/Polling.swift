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

import Foundation

/// Describes how aggressively to poll for a transaction receipt.
///
/// A `Polling` value bounds *how many* attempts are made (``count``), *how long to wait* before
/// the first attempt (``initialDelay``), and *how the wait grows* between attempts (``backoff``).
public struct Polling {
    /// Maximum number of poll attempts.
    public let count: Count
    /// How the wait between successive polls grows.
    public let backoff: Backoff
    /// Wait before the first poll attempt.
    public let initialDelay: Delay

    /// Designated initialiser.
    public init(
        _ count: Count,
        backoff: Backoff,
        initialDelay: Delay
    ) {
        self.count = count
        self.backoff = backoff
        self.initialDelay = initialDelay
    }
}

public extension Polling {
    /// A pragmatic default: 20 attempts, +2 s of linear back-off, with a 1 s warm-up. The total
    /// budget is roughly 7 minutes, which comfortably covers a single Zilliqa epoch.
    static var twentyTimesLinearBackoff: Polling {
        Polling(
            .twentyTimes,
            backoff: .linearIncrement(of: .twoSeconds),
            initialDelay: .oneSecond
        )
    }

    /// How the per-attempt wait grows between polls.
    enum Backoff {
        /// Each attempt waits an additional fixed ``Delay`` longer than the previous one.
        case linearIncrement(of: Delay)
    }

    /// A bounded set of supported wait durations, expressed in whole seconds.
    enum Delay: Int {
        case oneSecond = 1
        case twoSeconds = 2
        case threeSeconds = 3
        case fiveSeconds = 5
        case sevenSeconds = 7
        case tenSeconds = 10
        case twentySeconds = 20
    }

    /// A bounded set of attempt counts, useful for keeping pollers from looping forever.
    enum Count: Int {
        case once = 1
        case twice = 2
        case threeTimes = 3
        case fiveTimes = 5
        case tenTimes = 10
        case twentyTimes = 20
    }
}

extension Polling.Backoff {
    /// Applies the back-off function to the previous wait, returning the next wait in seconds.
    func add(to delayInSeconds: Int) -> Int {
        switch self {
        case let .linearIncrement(delayIncrement):
            delayInSeconds + delayIncrement.rawValue
        }
    }
}
