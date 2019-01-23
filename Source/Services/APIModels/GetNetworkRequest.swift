//
//  GetNetworkRequest.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct GetNetworkRequest: JSONRPCKit.Request {
    public typealias Response = NetworkResponse
}

public extension GetNetworkRequest {
    var method: String {
        return "GetNetworkId"
    }

    var parameters: Encodable? {
        return [""]
    }
}
