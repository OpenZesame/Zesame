//
//  ZilliqaRequest.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-09-10.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import JSONRPCKit
import APIKit

public struct ZilliqaRequest<Batch: JSONRPCKit.Batch>: APIKit.Request {
    public typealias Response = Batch.Responses
    public let batch: Batch
}

public extension ZilliqaRequest {
    var baseURL: URL {
        return URL(string: "https://scillaprod-api.aws.zilliqa.com")!
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/"
    }

    var parameters: Any? {
        return batch.requestObject
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try batch.responses(from: object)
    }
}

