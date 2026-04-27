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

/// Type-erased lower-bound check, mirroring ``AnyUpperbound``.
public struct AnyLowerbound {
    private let _withinBounds: (Any) throws -> Void
    /// Builds a bound checker for a ``Lowerbound`` type.
    init<L>(_: L.Type) where L: ExpressibleByAmount & Lowerbound {
        _withinBounds = {
            guard let value = $0 as? L.Magnitude else {
                fatalError("incorrect implementation")
            }
            guard value >= L.minInQa else {
                throw AmountError<L>.tooSmall(min: L.min)
            }
            // Yes is within bounds
        }
    }

    /// Validates `value` against the captured lower bound.
    public func throwErrorIfNotWithinBounds(_ value: Any) throws {
        try _withinBounds(value)
    }
}
