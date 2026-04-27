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

/// JSON-RPC 2.0 request envelope. Encodes to the wire format
/// `{ "id": …, "method": …, "params": …, "jsonrpc": "2.0" }`.
///
/// The envelope is transport-agnostic — `URLRequest` construction lives in the API client, not
/// here. This is a plain value type that knows how to encode itself as JSON.
public struct RPCRequest: Encodable {
    /// The unique request id (decimal string from ``RequestIdGenerator``). The JSON-RPC 2.0 spec
    /// allows string, number, or null; we use strings for simplicity.
    public let requestId: String

    /// The wire-level method name.
    public let method: String

    /// Parameter shape (none / positional / named).
    public let params: RPCParams

    /// JSON-RPC protocol version. Always `"2.0"`.
    public let version = "2.0"

    /// Designated initialiser. Auto-allocates an id from ``RequestIdGenerator``.
    public init(
        method: String,
        params: RPCParams = .none
    ) {
        requestId = RequestIdGenerator.nextId()
        self.method = method
        self.params = params
    }

    /// Convenience that pulls name + params from an ``RPCMethod``. Erases the response type
    /// because the response shape is the API client's concern, not the envelope's.
    public init(_ rpcMethod: RPCMethod<some Decodable>) {
        self.init(method: rpcMethod.name, params: rpcMethod.params)
    }
}

// MARK: - Encodable

public extension RPCRequest {
    /// JSON wire-format keys.
    enum CodingKeys: String, CodingKey {
        case requestId = "id"
        case method
        case params
        case version = "jsonrpc"
    }

    /// Custom encoder so we can omit the `params` field entirely for ``RPCParams/none``.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(method, forKey: .method)
        try params.encode(into: &container, forKey: .params)
        try container.encode(version, forKey: .version)
    }
}
