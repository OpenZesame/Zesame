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

/// A bounded amount type that has a minimum value. Throwing `-` is part of the contract — it may
/// surface ``AmountError/tooSmall`` when the result drops below ``minInQa``.
public protocol Lowerbound: Bound {
    /// Minimum allowed Qa magnitude.
    static var minInQa: Magnitude { get }
    /// Sentinel ``Self`` value at the lower bound.
    static var min: Self { get }
    /// Throwing subtraction; may produce ``AmountError/tooSmall``.
    static func - (
        lhs: Self,
        rhs: Self
    ) throws -> Self
}

public extension Lowerbound where Self: ExpressibleByAmount {
    /// Default sentinel for the lower bound. Force-tries because the value is, by definition,
    /// in-bounds.
    static var min: Self {
        try! Self(qa: minInQa)
    }
}
