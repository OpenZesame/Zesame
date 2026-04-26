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

/// JSONRPC method according to [Zilliqa API docs][1]
///
/// Each case carries the strongly-typed parameters that ``encodeValue(key:)`` knows how to
/// serialise into a JSON-RPC `params` array.
///
/// [1]: https://apidocs.zilliqa.com/#introduction
public enum RPCMethod {
    /// `GetBalance` for a legacy (hex) address.
    case getBalance(LegacyAddress)
    /// `CreateTransaction`, broadcasting a signed transaction.
    case createTransaction(SignedTransaction)
    /// `GetTransaction`, looking up a transaction by id.
    case getTransaction(TransactionId)
    /// `GetNetworkId`, no parameters.
    case getNetworkId
    /// `GetMinimumGasPrice`, no parameters.
    case getMinimumGasPrice
}

public extension RPCMethod {
    /// Closure type that encodes a method's parameter into a keyed container under `key`.
    typealias EncodeValue<K: CodingKey> = (inout KeyedEncodingContainer<K>) throws -> Void

    /// Wire-level method name as expected by the Zilliqa JSON-RPC API.
    var method: String {
        switch self {
        case .getBalance: "GetBalance"
        case .createTransaction: "CreateTransaction"
        case .getTransaction: "GetTransaction"
        case .getNetworkId: "GetNetworkId"
        case .getMinimumGasPrice: "GetMinimumGasPrice"
        }
    }

    /// Returns an encoder closure for the method's parameter, or `nil` for parameter-less methods.
    ///
    /// The Zilliqa JSON-RPC dialect always wraps parameters in an array — encoding a bare object
    /// triggers `INVALID_JSON_REQUEST`.
    func encodeValue<K: CodingKey>(key: K) -> EncodeValue<K>? {
        func innerEncode(_ value: some Encodable) -> EncodeValue<K> {
            { keyedEncodingContainer in
                // DO OBSERVE THE ARRAY! `[]`. We MUST put the encodable in an array, since that is how RPC
                // works. Otherwise we will get `INVALID_JSON_REQUEST`
                try keyedEncodingContainer.encode([value], forKey: key)
            }
        }

        switch self {
        case let .getBalance(address): return innerEncode(address)
        case let .createTransaction(signedTransaction): return innerEncode(signedTransaction)
        case let .getTransaction(txId): return innerEncode(txId)
        case .getNetworkId: return nil
        case .getMinimumGasPrice: return nil
        }
    }
}

/// Hex-encoded transaction hash returned by `CreateTransaction` and accepted by `GetTransaction`.
public typealias TransactionId = String
