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

/// Result body of `GetTransaction`. Used during polling to determine whether a transaction has
/// reached consensus.
public struct StatusOfTransactionResponse: Decodable {
    /// The receipt portion that callers actually inspect.
    public struct Receipt {
        /// Total gas consumed by the transaction (in Zil).
        public let totalGasCost: Amount
        /// `true` once the network has accepted the transaction.
        public let isSent: Bool
        /// Validator-reported errors keyed by shard. Non-empty means the transaction was
        /// permanently rejected — pollers should stop and surface the failure.
        public let errors: [String: [Int]]
        /// Scilla VM exceptions keyed by shard. Non-empty means contract execution failed.
        public let exceptions: [TransactionException]
    }

    /// Receipt populated by the node when the transaction has been processed.
    public let receipt: Receipt

    /// Single Scilla exception entry from the receipt's `exceptions` array.
    public struct TransactionException: Decodable, Equatable {
        /// Source-line of the exception in the contract code.
        public let line: Int?
        /// Human-readable exception message.
        public let message: String

        /// JSON wire keys.
        public enum CodingKeys: String, CodingKey {
            case line, message
        }
    }
}
