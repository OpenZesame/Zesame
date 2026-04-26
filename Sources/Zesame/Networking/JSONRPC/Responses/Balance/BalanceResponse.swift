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

/// Result body of `GetBalance`. Encodable for test purposes, this type is never sent TO the API,
/// only parsed FROM the API.
public struct BalanceResponse: Codable {
    /// Account balance (in Zil).
    public let balance: Amount
    /// Account nonce — incremented for every successfully-mined transaction from this account.
    public let nonce: Nonce

    /// Designated initialiser.
    public init(
        balance: Amount,
        nonce: Nonce
    ) {
        self.balance = balance
        self.nonce = nonce
    }

    /// JSON wire keys.
    public enum CodingKeys: CodingKey {
        case nonce, balance
    }

    /// Custom decoder; ``Amount`` and ``Nonce`` each have their own scalar decoders.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        balance = try container.decode(Amount.self, forKey: .balance)
        nonce = try container.decode(Nonce.self, forKey: .nonce)
    }
}

extension Nonce: Codable {
    /// Decodes the nonce from a single bare `UInt64` JSON value.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let nonce = try container.decode(UInt64.self)
        self.init(nonce)
    }

    /// Encodes the nonce as a single bare `UInt64` JSON value.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(nonce)
    }
}
