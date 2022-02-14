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
    private let baseURL: URL
    private let jsonDecoder = JSONDecoder()
    public init(baseURL: URL) {
        self.session = URLSession(configuration: .default)
        self.baseURL = baseURL
    }
}

public extension DefaultAPIClient {
    convenience init(endpoint: ZilliqaAPIEndpoint) {
        self.init(baseURL: endpoint.baseURL)
    }
}



// MARK: - APIClient
public extension DefaultAPIClient {
    
    enum HTTPError: Swift.Error {
        case badStatusCode(expected: Int, butGot: Int)
    }
    
    func send<T: Decodable>(method: RPCMethod) async throws -> T {
        
        let rpcRequest = RPCRequest(method: method)
        let urlRequest = try rpcRequest.asURLRequest(baseURL: baseURL)
        do {
            let (jsondata, response) = try await session.data(for: urlRequest)
            if let httpURLResponse = response as? HTTPURLResponse {
                let ok = 200
                if httpURLResponse.statusCode != ok {
                    let error = HTTPError.badStatusCode(expected: ok, butGot: httpURLResponse.statusCode)
                    throw Error.api(.request(error))
                }
            }
            return try jsonDecoder.decode(T.self, from: jsondata)
        } catch {
            throw Error.api(.request(error))
        }
    }
}
