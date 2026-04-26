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

/// `URLSession`-backed implementation of ``APIClient``. POSTs JSON-RPC envelopes to ``baseURL``.
public final class DefaultAPIClient: APIClient {
    private let session: URLSession
    /// The JSON-RPC endpoint URL all requests are POSTed to.
    public let baseURL: URL

    /// Creates a client that targets `baseURL` using a default-configured `URLSession`.
    public init(baseURL: URL) {
        self.baseURL = baseURL
        session = URLSession(configuration: .default)
    }
}

public extension DefaultAPIClient {
    /// Convenience initialiser that pulls the URL out of a known ``ZilliqaAPIEndpoint``.
    convenience init(endpoint: ZilliqaAPIEndpoint) {
        self.init(baseURL: endpoint.baseURL)
    }
}

// MARK: - APIClient

public extension DefaultAPIClient {
    /// HTTP-level failures that don't reach the JSON-RPC body decoder.
    enum HTTPError: Swift.Error, CustomStringConvertible {
        /// The response status code was outside `200..<300`.
        ///
        /// - Parameters:
        ///   - code: The HTTP status returned by the server.
        ///   - body: The raw response body (helpful when the node returns a plain-text 5xx page).
        case unacceptableStatusCode(code: Int, body: Data)

        /// Human-readable rendering, including the response body when UTF-8 decodable.
        public var description: String {
            switch self {
            case let .unacceptableStatusCode(code, body):
                let bodyString = String(data: body, encoding: .utf8) ?? "<non-utf8 \(body.count) bytes>"
                return "HTTP \(code): \(bodyString)"
            }
        }
    }

    /// POSTs the encoded ``RPCMethod`` to ``baseURL``, validates the HTTP status, and decodes the
    /// result. All failures are normalised to ``Zesame/Error/api(_:)``.
    func send<T: Decodable>(method: RPCMethod) async throws -> T {
        let rpcRequest = RPCRequest(method: method)
        do {
            let urlRequest = try rpcRequest.asURLRequest(baseURL: baseURL)
            let (data, response) = try await session.data(for: urlRequest)
            if let http = response as? HTTPURLResponse, !(200 ..< 300).contains(http.statusCode) {
                throw Zesame.Error.api(.request(
                    HTTPError.unacceptableStatusCode(code: http.statusCode, body: data)
                ))
            }
            let rpcResponse = try JSONDecoder().decode(RPCResponse<T>.self, from: data)
            switch rpcResponse {
            case let .rpcError(rpcError):
                throw Zesame.Error.api(.request(rpcError))
            case let .rpcSuccess(result):
                return result
            }
        } catch let error as Zesame.Error {
            throw error
        } catch {
            throw Zesame.Error.api(.request(error))
        }
    }
}
