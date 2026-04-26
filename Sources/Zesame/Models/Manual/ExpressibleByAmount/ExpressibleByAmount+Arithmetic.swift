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

public extension ExpressibleByAmount where Self: Bound {
    private static func qaFrom(
        _ lhs: Self,
        _ rhs: Self,
        calc: (Magnitude, Magnitude) -> Magnitude
    ) throws -> Self {
        try Self(qa: calc(lhs.qa, rhs.qa))
    }

    /// Throwing addition for bounded amounts — the result is re-validated against the type's
    /// bounds and may throw ``AmountError/tooLarge``.
    static func + (
        lhs: Self,
        rhs: Self
    ) throws -> Self {
        try qaFrom(lhs, rhs) { $0 + $1 }
    }

    /// Throwing multiplication for bounded amounts.
    static func * (
        lhs: Self,
        rhs: Self
    ) throws -> Self {
        try qaFrom(lhs, rhs) { $0 * $1 }
    }

    /// Throwing subtraction for bounded amounts — the result is re-validated and may throw
    /// ``AmountError/tooSmall`` for negative results on non-negative-bounded types.
    static func - (
        lhs: Self,
        rhs: Self
    ) throws -> Self {
        try qaFrom(lhs, rhs) { $0 - $1 }
    }
}

public extension ExpressibleByAmount where Self: Unbound {
    /// Subtraction on unbounded amounts. Cannot throw; the result is computed in `BigInt`, which
    /// is signed and arbitrary-precision, so a "negative" result is permitted at the type level.
    /// Bounded conformers (e.g. ``Amount``) re-validate via their own throwing operators.
    static func - (
        lhs: Self,
        rhs: Self
    ) -> Self {
        qaFrom(lhs, rhs) { $0 - $1 }
    }

    /// Helper that lifts a Qa-magnitude binary operation back into `Self`.
    private static func qaFrom(
        _ lhs: Self,
        _ rhs: Self,
        calc: (Magnitude, Magnitude) -> Magnitude
    ) -> Self {
        Self(qa: calc(lhs.qa, rhs.qa))
    }

    /// Addition on unbounded amounts.
    static func + (
        lhs: Self,
        rhs: Self
    ) -> Self {
        Self(qa: lhs.qa + rhs.qa)
    }

    /// Multiplication on unbounded amounts.
    static func * (
        lhs: Self,
        rhs: Self
    ) -> Self {
        Self(qa: lhs.qa * rhs.qa)
    }
}

/// Heterogeneous addition — `lhs` defines the result type, `rhs` is reduced to Qa first.
public func + <A: ExpressibleByAmount & Bound>(
    lhs: A,
    rhs: some ExpressibleByAmount
) throws -> A {
    try A(qa: lhs.qa + rhs.qa)
}

/// Heterogeneous addition for unbounded result types — see the bounded overload.
public func + <A: ExpressibleByAmount & Unbound>(
    lhs: A,
    rhs: some ExpressibleByAmount
) -> A {
    A(qa: lhs.qa + rhs.qa)
}

/// Heterogeneous subtraction — `lhs` defines the result type, `rhs` is reduced to Qa first.
public func - <A: ExpressibleByAmount & Bound>(
    lhs: A,
    rhs: some ExpressibleByAmount
) throws -> A {
    try A(qa: lhs.qa - rhs.qa)
}

/// Heterogeneous subtraction for unbounded result types.
public func - <A: ExpressibleByAmount & Unbound>(
    lhs: A,
    rhs: some ExpressibleByAmount
) -> A {
    A(qa: lhs.qa - rhs.qa)
}
