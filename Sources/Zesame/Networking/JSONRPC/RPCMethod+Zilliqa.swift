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

/// Hex-encoded transaction hash returned by `CreateTransaction` and accepted by `GetTransaction`.
public typealias TransactionId = String

// MARK: - Zilliqa method bindings

//
// Each `static` factory below pins the method name + parameter shape to the response type,
// so call sites read as `apiClient.send(method: .getBalance(addr))` and the response type
// (`BalanceResponse`) is inferred automatically.
//
// See [Zilliqa API docs](https://apidocs.zilliqa.com/#introduction) for the wire spec.

public extension RPCMethod where Response == BalanceResponse {
    /// `GetBalance` — fetches account balance and nonce for a legacy hex address.
    static func getBalance(_ address: LegacyAddress) -> Self {
        RPCMethod(name: "GetBalance", params: .positional(address))
    }
}

public extension RPCMethod where Response == TransactionResponse {
    /// `CreateTransaction` — broadcasts a signed transaction.
    static func createTransaction(_ transaction: SignedTransaction) -> Self {
        RPCMethod(name: "CreateTransaction", params: .positional(transaction))
    }
}

public extension RPCMethod where Response == StatusOfTransactionResponse {
    /// `GetTransaction` — looks up a transaction's status by hash.
    static func getTransaction(_ id: TransactionId) -> Self {
        RPCMethod(name: "GetTransaction", params: .positional(id))
    }
}

public extension RPCMethod where Response == NetworkResponse {
    /// `GetNetworkId` — reads the connected node's network identifier. No parameters.
    static var getNetworkId: Self {
        RPCMethod(name: "GetNetworkId")
    }
}

public extension RPCMethod where Response == MinimumGasPriceResponse {
    /// `GetMinimumGasPrice` — reads the network's current minimum gas price. No parameters.
    static var getMinimumGasPrice: Self {
        RPCMethod(name: "GetMinimumGasPrice")
    }
}
