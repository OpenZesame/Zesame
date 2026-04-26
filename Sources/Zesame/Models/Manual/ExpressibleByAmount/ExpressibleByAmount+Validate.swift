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

public extension ExpressibleByAmount where Self: Upperbound, Self: Lowerbound {
    /// Validates against both bounds; throws ``AmountError/tooSmall`` or ``AmountError/tooLarge``.
    static func validate(value: Magnitude) throws -> Magnitude {
        try AnyLowerbound(self).throwErrorIfNotWithinBounds(value)
        try AnyUpperbound(self).throwErrorIfNotWithinBounds(value)
        return value
    }
}

public extension ExpressibleByAmount where Self: Upperbound & NoLowerbound {
    /// Validates against the upper bound only.
    static func validate(value: Magnitude) throws -> Magnitude {
        try AnyUpperbound(self).throwErrorIfNotWithinBounds(value)
        return value
    }
}

public extension ExpressibleByAmount where Self: Lowerbound, Self: NoUpperbound {
    /// Validates against the lower bound only.
    static func validate(value: Magnitude) throws -> Magnitude {
        try AnyLowerbound(self).throwErrorIfNotWithinBounds(value)
        return value
    }
}

public extension ExpressibleByAmount where Self: Unbound {
    /// No-op validation: unbounded types accept any magnitude.
    static func validate(value: Magnitude) throws -> Magnitude {
        value
    }
}
