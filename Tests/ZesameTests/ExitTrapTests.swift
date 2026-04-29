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
import Testing
@testable import Zesame

/// Process-exit tests for the `fatalError` / `preconditionFailure` traps in the public API.
/// Each `#expect(processExitsWith: .failure)` runs its closure in a child process and asserts the
/// process terminates abnormally — this is the only way to drive coverage through `Never`-returning
/// trap sites without crashing the host test runner.
struct ExitTrapTests {
    // MARK: - ExpressibleByAmount+Bound traps

    @Test func amountValidInitTrapsOnOutOfBoundsMagnitude() async {
        await #expect(processExitsWith: .failure) {
            _ = Amount(valid: Amount.maxInQa + 1)
        }
    }

    @Test func amountFloatLiteralTrapsOnOutOfBoundsValue() async {
        await #expect(processExitsWith: .failure) {
            _ = Amount(floatLiteral: -1.0)
        }
    }

    @Test func amountIntegerLiteralTrapsOnOutOfBoundsValue() async {
        await #expect(processExitsWith: .failure) {
            _ = Amount(integerLiteral: -1)
        }
    }

    @Test func amountStringLiteralTrapsOnNonNumericString() async {
        await #expect(processExitsWith: .failure) {
            _ = Amount(stringLiteral: "not-a-number")
        }
    }

    // MARK: - GasPrice bounds traps

    @Test func gasPriceMinSetterTrapsWhenAboveMax() async {
        await #expect(processExitsWith: .failure) {
            GasPrice.minInQa = GasPrice.maxInQa + 1
        }
    }

    @Test func gasPriceMaxSetterTrapsWhenBelowMin() async {
        await #expect(processExitsWith: .failure) {
            GasPrice.maxInQa = GasPrice.minInQa - 1
        }
    }

    // MARK: - HexString traps

    @Test func hexStringChecksummedTrapsOnWrongLength() async {
        await #expect(processExitsWith: .failure) {
            guard let hex = try? HexString("ab") else { return }
            _ = hex.checksummed
        }
    }

    @Test func hexStringLiteralTrapsOnNonHex() async {
        await #expect(processExitsWith: .failure) {
            _ = HexString(stringLiteral: "zzzz")
        }
    }
}
