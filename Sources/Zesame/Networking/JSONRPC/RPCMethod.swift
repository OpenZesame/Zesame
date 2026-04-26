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

/// A binding from a JSON-RPC method name + parameters to its expected `Response` type.
///
/// `RPCMethod` is generic and open-ended: clients add new methods by writing static factories in
/// constrained extensions, not by editing this library. Carrying the response type as a
/// type parameter lets ``APIClient/send(method:)`` infer the return type at the call site —
/// `let balance = try await apiClient.send(method: .getBalance(addr))` resolves to
/// `BalanceResponse` without an explicit annotation.
///
/// Example — adding a new method in client code:
/// ```swift
/// extension RPCMethod where Response == MyBlockResponse {
///     static func getBlock(_ height: Int) -> Self {
///         RPCMethod(name: "GetBlock", params: .positional(height))
///     }
/// }
/// ```
public struct RPCMethod<Response: Decodable> {
    /// Wire-level method name as the server expects it.
    public let name: String

    /// Parameters to send with the call.
    public let params: RPCParams

    /// Designated initialiser.
    public init(
        name: String,
        params: RPCParams = .none
    ) {
        self.name = name
        self.params = params
    }
}
