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
import Alamofire

public final class DefaultAPIClient: APIClient {
    

    private let session: Alamofire.Session
    private unowned let interceptor: SimpleRequestAdapter
    
    public init(baseURL: URL) {
        let interceptor = SimpleRequestAdapter(baseURL: baseURL)
        self.session = Alamofire.Session(interceptor: interceptor)
        self.interceptor = interceptor
    }
}

public extension DefaultAPIClient {
    convenience init(endpoint: ZilliqaAPIEndpoint) {
        self.init(baseURL: endpoint.baseURL)
    }
}

public extension DefaultAPIClient {
    var baseURL: URL { interceptor.baseURL }
}

// MARK: - RequestInterceptor (RequestAdapter)
private extension DefaultAPIClient {
    
    final class SimpleRequestAdapter: RequestInterceptor {
        fileprivate let baseURL: URL
        init(baseURL: URL) {
            self.baseURL = baseURL
        }
        
        func adapt(
            _ urlRequest: URLRequest,
            for session: Alamofire.Session,
            completion: @escaping (Result<URLRequest, Swift.Error>) -> Void
        ) {
            var urlRequest = urlRequest
            if urlRequest.url?.absoluteString.isEmpty == true || urlRequest.url?.absoluteString == "/" {
                urlRequest.url = baseURL
            }
            completion(.success(urlRequest))
        }
        
        func retry(
            _ request: Alamofire.Request,
            for session: Alamofire.Session,
            dueTo error: Swift.Error,
            completion: @escaping (Alamofire.RetryResult) -> Void
        ) {
            completion(.doNotRetry)
        }
        
    }
}

// MARK: - APIClient
public extension DefaultAPIClient {
    
    func send<ResultFromResponse>(
        method: RPCMethod, 
        done: @escaping Done<ResultFromResponse>
    ) where ResultFromResponse: Decodable {
        
        let rpcRequest = RPCRequest(method: method)

        session.request(rpcRequest)
            .validate()
            .responseDecodable { (response: DataResponse<RPCResponse<ResultFromResponse>, AFError>) in
            switch response.result {
            case .success(let successOrRPCError):
                switch successOrRPCError {
                case .rpcError(let rpcErrorOrDecodeToRPCErrorMetaError):
                    done(.failure(.api(.request(rpcErrorOrDecodeToRPCErrorMetaError))))
                case .rpcSuccess(let resultFromResponse):
                    done(.success(resultFromResponse))
                }
            case .failure(let error):
                done(.failure(.api(.request(error))))
            }
        }
    }
}
