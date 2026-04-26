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
    /// Default per-request timeout (30 s) — overrides the `URLSession` default of 60 s, which is
    /// too long for an interactive wallet UI.
    public static let defaultRequestTimeout: TimeInterval = 30

    /// Default whole-resource timeout (60 s) — overrides the `URLSession` default of 7 days.
    public static let defaultResourceTimeout: TimeInterval = 60

    private let session: URLSession
    /// The JSON-RPC endpoint URL all requests are POSTed to.
    public let baseURL: URL

    /// Creates a client that targets `baseURL` using a `URLSession` configured with the supplied
    /// timeouts. The defaults bound interactive UI hangs.
    public init(
        baseURL: URL,
        requestTimeout: TimeInterval = DefaultAPIClient.defaultRequestTimeout,
        resourceTimeout: TimeInterval = DefaultAPIClient.defaultResourceTimeout
    ) {
        self.baseURL = baseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = requestTimeout
        config.timeoutIntervalForResource = resourceTimeout
        session = URLSession(configuration: config)
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
    /// result as the method's bound ``RPCMethod/Response`` type. All failures are normalised to
    /// ``Zesame/Error/api(_:)``.
    func send<Response: Decodable>(method: RPCMethod<Response>) async throws -> Response {
        let rpcRequest = RPCRequest(method)
        do {
            let urlRequest = try Self.urlRequest(for: rpcRequest, baseURL: baseURL)
            let (data, response) = try await session.data(for: urlRequest)
            if let http = response as? HTTPURLResponse, !(200 ..< 300).contains(http.statusCode) {
                throw Zesame.Error.api(.request(
                    HTTPError.unacceptableStatusCode(code: http.statusCode, body: data)
                ))
            }
            let rpcResponse = try JSONDecoder().decode(RPCResponse<Response>.self, from: data)
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

    /// Renders an ``RPCRequest`` as a `POST` `URLRequest` with a JSON body and the standard
    /// `application/json` content type. Internal helper kept on the client to keep the JSON-RPC
    /// envelope transport-agnostic.
    private static func urlRequest(
        for rpcRequest: RPCRequest,
        baseURL: URL
    ) throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(rpcRequest)
        return urlRequest
    }
}
