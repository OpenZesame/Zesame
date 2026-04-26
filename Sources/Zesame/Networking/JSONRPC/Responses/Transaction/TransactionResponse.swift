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

/// Result body of `CreateTransaction`. Returned immediately after broadcast — the network has not
/// necessarily reached consensus yet; use ``TransactionReceipt`` for confirmation.
public struct TransactionResponse: Decodable {
    /// Free-form status string from the node (typically `"Non-contract txn, sent to shard"`).
    public let info: String
    /// Hex-encoded transaction id usable for `GetTransaction` lookups.
    public let transactionIdentifier: String

    /// JSON wire keys; the Zilliqa API uses PascalCase here.
    public enum CodingKeys: String, CodingKey {
        case transactionIdentifier = "TranID"
        case info = "Info"
    }
}
