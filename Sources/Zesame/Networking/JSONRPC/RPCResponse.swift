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

/// Either a successful JSON-RPC result of type `ResultFromResponse` or an error envelope.
public enum RPCResponse<ResultFromResponse: Decodable>: Decodable {
    /// Successfully-decoded result body.
    case rpcSuccess(ResultFromResponse)
    /// An error envelope or a decoding failure of either branch.
    case rpcError(Swift.Error)
}

// MARK: - Decodable

public extension RPCResponse {
    /// Tries to decode the success envelope first; on failure falls back to ``RPCError``; if
    /// *that* also fails, the decoder error itself is captured so the caller never has to deal
    /// with a thrown value at this layer.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .rpcSuccess(container.decode(RPCResponseSuccess<ResultFromResponse>.self).result)
        } catch {
            do {
                self = try .rpcError(container.decode(RPCError.self) as Swift.Error)
            } catch let decodeAsErrorMetaError {
                self = .rpcError(decodeAsErrorMetaError)
            }
        }
    }
}
