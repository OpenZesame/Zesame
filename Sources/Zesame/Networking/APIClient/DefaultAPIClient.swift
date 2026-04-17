//
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
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

public final class DefaultAPIClient: APIClient {
    private let session: URLSession
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
        session = URLSession(configuration: .default)
    }
}

public extension DefaultAPIClient {
    convenience init(endpoint: ZilliqaAPIEndpoint) {
        self.init(baseURL: endpoint.baseURL)
    }
}

// MARK: - APIClient

public extension DefaultAPIClient {
    func send<ResultFromResponse: Decodable>(
        method: RPCMethod,
        done: @escaping Done<ResultFromResponse>
    ) {
        let rpcRequest = RPCRequest(method: method)

        do {
            var urlRequest = try rpcRequest.asURLRequest()
            urlRequest.url = baseURL

            session.dataTask(with: urlRequest) { data, _, error in
                if let error {
                    done(.failure(.api(.request(error))))
                    return
                }
                guard let data else {
                    done(.failure(.api(.request(URLError(.badServerResponse)))))
                    return
                }
                do {
                    let rpcResponse = try JSONDecoder().decode(RPCResponse<ResultFromResponse>.self, from: data)
                    switch rpcResponse {
                    case let .rpcError(rpcError):
                        done(.failure(.api(.request(rpcError))))
                    case let .rpcSuccess(result):
                        done(.success(result))
                    }
                } catch {
                    done(.failure(.api(.request(error))))
                }
            }.resume()
        } catch {
            done(.failure(.api(.request(error))))
        }
    }
}
