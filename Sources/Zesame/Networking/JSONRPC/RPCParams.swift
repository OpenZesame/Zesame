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

/// Parameter shape carried by a JSON-RPC 2.0 request.
///
/// The JSON-RPC 2.0 spec lets `params` be omitted, an array (positional), or an object (named).
/// Zilliqa uses positional everywhere — a bare object triggers `INVALID_JSON_REQUEST` — but the
/// generic envelope supports all three so the JSON-RPC core can be reused for other servers.
public enum RPCParams {
    /// No `params` field on the wire.
    case none

    /// Positional parameters, encoded as a JSON array. The Zilliqa convention.
    case positional([any Encodable])

    /// Named parameters, encoded as a JSON object. Standard JSON-RPC 2.0; not used by Zilliqa.
    case named([String: any Encodable])
}

public extension RPCParams {
    /// Convenience for the common single-value positional case.
    static func positional(_ value: any Encodable) -> RPCParams {
        .positional([value])
    }
}

extension RPCParams {
    /// Encodes the params into the request's keyed container under `key`, or no-ops for `.none`.
    func encode<Key: CodingKey>(
        into container: inout KeyedEncodingContainer<Key>,
        forKey key: Key
    ) throws {
        switch self {
        case .none:
            return
        case let .positional(values):
            try container.encode(values.map(AnyEncodable.init), forKey: key)
        case let .named(values):
            try container.encode(values.mapValues(AnyEncodable.init), forKey: key)
        }
    }
}
