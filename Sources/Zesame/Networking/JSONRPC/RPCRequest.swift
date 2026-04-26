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

/// JSON-RPC 2.0 request envelope. Values of this type encode straight to the wire format the node
/// expects: `{ "id": …, "method": …, "params": [ … ], "jsonrpc": "2.0" }`.
public struct RPCRequest: Encodable {
    /// The RPC method name, e.g. `"GetBalance"`.
    public let rpcMethod: String
    /// Type-erased closure that knows how to encode the method's parameters into the keyed
    /// container. `nil` for parameter-less methods like `GetNetworkId`.
    private let _encodeValue: RPCMethod.EncodeValue<CodingKeys>?
    /// The unique request id (decimal string from ``RequestIdGenerator``).
    public let requestId: String
    /// JSON-RPC protocol version. Always `"2.0"`.
    public let version = "2.0"

    /// Designated initialiser. Captures `encodeValue` lazily so that parameter encoding happens at
    /// `encode(to:)` time, not at construction.
    public init(
        rpcMethod: String,
        encodeValue: RPCMethod.EncodeValue<CodingKeys>?
    ) {
        self.rpcMethod = rpcMethod
        _encodeValue = encodeValue
        requestId = RequestIdGenerator.nextId()
    }
}

// MARK: - Convenience Init

public extension RPCRequest {
    /// Convenience initialiser that pulls the method name and parameter-encoder from
    /// ``RPCMethod``.
    init(method: RPCMethod) {
        self.init(rpcMethod: method.method, encodeValue: method.encodeValue(key: .parameters))
    }
}

// MARK: - Encodable

public extension RPCRequest {
    /// JSON wire-format keys.
    enum CodingKeys: String, CodingKey {
        case requestId = "id"
        case rpcMethod = "method"
        case parameters = "params"
        case version = "jsonrpc"
    }

    /// Custom encoder that delegates parameter writing to the captured ``EncodeValue`` closure when
    /// present.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(rpcMethod, forKey: .rpcMethod)
        if let encodeValue = _encodeValue {
            try encodeValue(&container)
        }
        try container.encode(version, forKey: .version)
    }
}

// MARK: - URLRequest

extension RPCRequest {
    /// Renders the request as a `POST` `URLRequest` with the JSON body and `application/json`
    /// content type.
    func asURLRequest(baseURL: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(self)
        return urlRequest
    }
}
