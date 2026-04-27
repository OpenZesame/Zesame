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

/// Decoded form of a JSON-RPC 2.0 error envelope returned by a Zilliqa node.
public struct RPCError: Swift.Error, Decodable {
    /// The JSON-RPC `id` field, echoing the originating request's identifier.
    public let requestId: String
    /// Human-readable error message provided by the node.
    public let errorMessage: String
    /// Strongly-typed error code (recognised constants, an unknown integer, or a parse failure).
    public let errorCode: RPCErrorCode
}

public extension RPCError {
    /// Wire shape of the nested `error` object inside a JSON-RPC error envelope.
    private struct InnerError: Decodable {
        /// Numeric error code.
        public let code: RPCErrorCode
        /// Human-readable message.
        public let message: String
    }

    /// JSON keys for the top-level error envelope.
    enum CodingKeys: String, CodingKey {
        case error
        case requestId = "id"
    }

    /// Custom decoder that flattens the nested `error` object into ``errorCode`` / ``errorMessage``.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        requestId = try container.decode(String.self, forKey: .requestId)
        let innerError = try container.decode(InnerError.self, forKey: .error)
        errorCode = innerError.code
        errorMessage = innerError.message
    }
}

/// Tri-state classification of a JSON-RPC error code.
public enum RPCErrorCode: Decodable {
    /// The decoder accepted the integer, but it isn't one of the recognised constants.
    case unrecognizedError(code: Int)
    /// The `code` field couldn't even be decoded as an integer; the underlying decoding error is
    /// captured for diagnostics.
    case failedToParseErrorCode(metaError: Swift.Error)
    /// One of the standard JSON-RPC 2.0 codes, mapped to ``RPCErrorCodeRecognized``.
    case recognizedRPCError(RPCErrorCodeRecognized)
}

public extension RPCErrorCode {
    /// Best-effort decoder: tries the recognised set first, falls back to a raw `Int`, and finally
    /// records the decoder error rather than throwing — so a deserialised request always carries a
    /// usable error code, even from a misbehaving node.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .recognizedRPCError(container.decode(RPCErrorCodeRecognized.self))
        } catch {
            do {
                self = try .unrecognizedError(code: container.decode(Int.self))
            } catch let decodeErrorCodeMetaError {
                self = .failedToParseErrorCode(metaError: decodeErrorCodeMetaError)
            }
        }
    }
}

/// Standard JSON-RPC 2.0 errors, as defined by [Zilliqa JS library][1]
/// [1]: https://github.com/Zilliqa/Zilliqa-JavaScript-Library/blob/76fed2012f0f3d6a081402e0c5d3f015ba15a7be/packages/zilliqa-js-core/src/net.ts#L52-L77
public enum RPCErrorCodeRecognized: Int, Decodable, Equatable {
    /// The JSON sent is not a valid Request object.
    case invalidRequest = -32600
    /// The method does not exist or is not available.
    case methodNotFound = -32601
    /// Invalid method parameter(s).
    case invalidParams = -32602
    /// Internal JSON-RPC error.
    case internalError = -32603
    /// Invalid JSON was received by the server.
    case parseError = -32700
}
