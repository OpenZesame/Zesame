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

/// Abstraction over the JSON-RPC transport. Tests inject stubs; production uses
/// ``DefaultAPIClient`` over `URLSession`.
public protocol APIClient {
    /// Encodes `method` as a JSON-RPC 2.0 request, sends it, and decodes the result as the
    /// method's bound `Response` type. Throws ``Zesame/Error/api(_:)`` on transport, HTTP, or
    /// RPC-level failure.
    ///
    /// The return type is inferred from the ``RPCMethod`` binding; call sites don't need to
    /// annotate it.
    func send<Response: Decodable>(method: RPCMethod<Response>) async throws -> Response
}
