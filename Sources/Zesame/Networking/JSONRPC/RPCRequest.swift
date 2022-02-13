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

public struct RPCRequest: Encodable {
    public let rpcMethod: String
    private let _encodeValue: RPCMethod.EncodeValue<CodingKeys>?
    public let requestId: String
    public let version = "2.0"
    
    public init(rpcMethod: String, encodeValue: RPCMethod.EncodeValue<CodingKeys>?) {
        self.rpcMethod = rpcMethod
        self._encodeValue = encodeValue
        self.requestId = RequestIdGenerator.nextId()
    }
}

// MARK: - Convenience Init
public extension RPCRequest {
    init(method: RPCMethod) {
        self.init(rpcMethod: method.method, encodeValue: method.encodeValue(key: .parameters))
    }
}

// MARK: - Encodable
public extension RPCRequest {
    enum CodingKeys: String, CodingKey {
        case requestId = "id"
        case rpcMethod = "method"
        case parameters = "params"
        case version = "jsonrpc"
    }
    
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

public extension RPCRequest {
    
    
    
    func asURLRequest(baseURL: URL) throws -> URLRequest {
        
        var components = URLComponents()
        components.path = "/"
        
        guard let relativeURL = components.url else {
            preconditionFailure("Failed to construct relative URL")
        }
        
        let url = baseURL.appendingPathComponent(relativeURL.path)
        print("🛰 making network request to URL: `\(url.absoluteString)`")
        var urlRequest = URLRequest(url: url)
        
        // HTTP Method
        urlRequest.httpMethod = "POST"
        
        // Common Headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONEncoder().encode(self)
        urlRequest.httpBody = jsonData
        
        return urlRequest
    }
}
