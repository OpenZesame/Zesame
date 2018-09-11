//
//  TransactionRequest.swift
//  ZilliqaSDK iOS
//
//  Created by Alexander Cyon on 2018-09-10.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct TransactionRequest: JSONRPCKit.Request {
    public typealias Response = Dictionary<String, Any>

    public let transaction: Transaction
    public init(transaction: Transaction) {
        self.transaction = transaction
    }
}

public extension TransactionRequest {
    var method: String {
        return "CreateTransaction"
    }

    var parameters: Any? {
        return [try! transaction.asDictionary()]
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw Error.json(.cast(actualValue: resultObject, expectedType: Response.self))
        }
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
