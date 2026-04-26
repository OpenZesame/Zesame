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

    /// Designated initialiser. Uses the bounded ``Count``/``Delay`` enums for type-safe defaults;
    /// for arbitrary intervals use ``init(attempts:initialDelaySeconds:linearBackoffSeconds:)``.
    public init(
        _ count: Count,
        backoff: Backoff,
        initialDelay: Delay
    ) {
        self.count = count
        self.backoff = backoff
        self.initialDelay = initialDelay
    }

    /// Free-form initialiser accepting arbitrary attempt counts and waits in whole seconds.
    /// Internally maps onto a synthetic `Count`/`Delay` whose `rawValue` is the supplied integer.
    /// Use this when the bounded enums don't cover your desired schedule.
    ///
    /// - Parameters:
    ///   - attempts: Total number of attempts; must be `>= 1`.
    ///   - initialDelaySeconds: Seconds to wait before the first poll; must be `>= 0`.
    ///   - linearBackoffSeconds: Seconds to add between consecutive attempts (linear back-off);
    ///     must be `>= 0`.
    public init(
        attempts: Int,
        initialDelaySeconds: Int,
        linearBackoffSeconds: Int
    ) {
        precondition(attempts >= 1, "Polling.attempts must be >= 1, got \(attempts)")
        precondition(initialDelaySeconds >= 0, "initialDelaySeconds must be >= 0, got \(initialDelaySeconds)")
        precondition(linearBackoffSeconds >= 0, "linearBackoffSeconds must be >= 0, got \(linearBackoffSeconds)")
        count = Count(rawSeconds: attempts)
        initialDelay = Delay(rawSeconds: initialDelaySeconds)
        backoff = .linearIncrement(of: Delay(rawSeconds: linearBackoffSeconds))
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

    /// A wait duration, in whole seconds. The named cases cover the common schedules; use
    /// ``init(rawSeconds:)`` for arbitrary intervals.
    struct Delay: Equatable {
        /// The wait, in seconds.
        public let rawValue: Int

        /// Wraps an arbitrary positive integer as a `Delay`. Prefer the named statics
        /// (``oneSecond``, ``twoSeconds``, …) where they fit.
        public init(rawSeconds seconds: Int) {
            rawValue = seconds
        }

        public static let oneSecond = Delay(rawSeconds: 1)
        public static let twoSeconds = Delay(rawSeconds: 2)
        public static let threeSeconds = Delay(rawSeconds: 3)
        public static let fiveSeconds = Delay(rawSeconds: 5)
        public static let sevenSeconds = Delay(rawSeconds: 7)
        public static let tenSeconds = Delay(rawSeconds: 10)
        public static let twentySeconds = Delay(rawSeconds: 20)
    }

    /// An attempt count. The named cases cover common schedules; use ``init(rawSeconds:)`` for
    /// arbitrary counts. (The label `rawSeconds` is reused for symmetry with ``Delay``; it's
    /// just a wrapped `Int`.)
    struct Count: Equatable {
        /// Total attempts.
        public let rawValue: Int

        /// Wraps an arbitrary positive integer as a `Count`.
        public init(rawSeconds value: Int) {
            rawValue = value
        }

        public static let once = Count(rawSeconds: 1)
        public static let twice = Count(rawSeconds: 2)
        public static let threeTimes = Count(rawSeconds: 3)
        public static let fiveTimes = Count(rawSeconds: 5)
        public static let tenTimes = Count(rawSeconds: 10)
        public static let twentyTimes = Count(rawSeconds: 20)
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
