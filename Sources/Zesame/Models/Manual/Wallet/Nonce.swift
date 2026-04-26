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

/// Account nonce — the count of mined transactions originated by an account.
///
/// The Zilliqa network expects each new transaction to use `current_nonce + 1`. ``Nonce`` wraps
/// the raw `UInt64` to keep that semantic distinct in the type system.
public struct Nonce {
    /// The wrapped nonce value.
    public let nonce: UInt64
    /// Wraps a raw `UInt64`, defaulting to zero (the nonce of a brand-new account).
    public init(_ nonce: UInt64 = 0) {
        self.nonce = nonce
    }
}

public extension Nonce {
    /// Returns a copy with `nonce + 1` — the value the next outgoing transaction should carry.
    func increasedByOne() -> Nonce {
        Nonce(nonce + 1)
    }
}

extension Nonce: ExpressibleByIntegerLiteral {
    /// Allows `Nonce`s to be written as integer literals.
    ///
    /// Negative literals trap with a clear precondition message rather than relying on the
    /// `UInt64(_: Int)` arithmetic trap, which is opaque at the call site.
    public init(integerLiteral value: Int) {
        precondition(value >= 0, "Nonce literal must be non-negative, got \(value)")
        self.init(UInt64(value))
    }
}

extension Nonce: Equatable {}
