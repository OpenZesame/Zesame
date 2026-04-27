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

/// Internal representation of a transaction prior to signing — a ``Payment`` plus the wire
/// ``Version`` and optional Scilla `code`/`data` payloads for contract calls.
///
/// `internal` because external callers shouldn't construct unsigned transactions directly; the
/// signing path inside ``ZilliqaService`` builds these from ``Payment`` and immediately wraps
/// them in a ``SignedTransaction`` for broadcast.
struct Transaction {
    /// Packed chain id + transaction version.
    let version: Version
    /// The transfer being made.
    let payment: Payment
    /// Optional Scilla call data (function & arguments) for contract calls.
    let data: String?
    /// Optional Scilla source code, set when deploying a new contract.
    let code: String?

    /// Memberwise initialiser. `data` and `code` default to `nil` for plain Zil transfers.
    init(
        payment: Payment,
        version: Version,
        data: String? = nil,
        code: String? = nil
    ) {
        self.version = version
        self.payment = payment
        self.data = data
        self.code = code
    }
}
