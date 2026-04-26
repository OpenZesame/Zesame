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

/// An upper bound whose value can be adjusted at runtime. Used by ``GasPrice``, where the
/// network's accepted maximum may shift over time.
public protocol AdjustableUpperbound: Upperbound {
    /// Factory-default upper bound, restored by ``restoreDefaultMax()``.
    static var maxInQaDefault: Magnitude { get }
    /// Mutable active upper bound.
    static var maxInQa: Magnitude { get set }
    /// Resets ``maxInQa`` to ``maxInQaDefault``.
    static func restoreDefaultMax()
}

public extension AdjustableUpperbound {
    /// Default implementation of ``restoreDefaultMax()``.
    static func restoreDefaultMax() {
        maxInQa = maxInQaDefault
    }
}
