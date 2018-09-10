//
//  BalanceRequest.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-09-10.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct BalanceRequest: JSONRPCKit.Request {
    public typealias Response = Dictionary<String, Any>

    public let publicAddress: String
    public init(publicAddress: String) {
        self.publicAddress = publicAddress
    }
}

public extension BalanceRequest {
    var method: String {
        return "GetBalance"
    }

    var parameters: Any? {
        return [publicAddress]
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw Error.json(.cast(actualValue: resultObject, expectedType: Response.self))
        }
    }
}
