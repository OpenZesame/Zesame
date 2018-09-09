//
//  ZilliqaService.swift
//  ZilliqaSDK iOS
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import JSONRPCKit
import Result
import APIKit

public enum Error: Swift.Error {
    case cast(actualValue: Any, expectedType: Any)
}

public protocol ZilliqaService {
    var wallet: Wallet { get }
//    func getBalalance(handleResult: (Result<Double, Error>) -> Void)
    func getBalalance(handleResult: @escaping (BalanceResponse) -> Void)
}

public final class DefaultZilliqaService: ZilliqaService {
    public let wallet: Wallet

    private let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())

    public init(wallet: Wallet) {
        self.wallet = wallet
    }
}

//typealias APIKitHandler<Response> = (Result<Response, APIKit.SessionTaskError>) -> Void
//typealias Handler<Response> = (Result<Response, Error>) -> Void
//func mapHandler(handler: @escaping )

public extension DefaultZilliqaService {
    func getBalalance(handleResult: @escaping (BalanceResponse) -> Void) {
        let request = BalanceRequest(publicAddress: wallet.address.address)
        let batch = batchFactory.create(request)
        let httpRequest = ServiceRequest(batch: batch)

        let _: SessionTask? = Session.send(httpRequest, callbackQueue: nil) { result in
            switch result {
            case .success(let response):
                let dictionary: [String: Any] = response
                let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
                let jsonDecoder = JSONDecoder()
                let balance = try! jsonDecoder.decode(BalanceResponse.self, from: jsonData)
                handleResult(balance)
            case .failure(let error):
                print("failed with error: `\(error)`")
            }
        }
    }
}

public struct ServiceRequest<Batch: JSONRPCKit.Batch>: APIKit.Request {
    public typealias Response = Batch.Responses
    public let batch: Batch
}

public extension ServiceRequest {
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

public struct BalanceResponse: Decodable {
    public let balance: String
    public let nonce: Int
}

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
            print("ERROR. here is mirror")
            let mirror = Mirror(reflecting: resultObject)
            print(mirror)
            print(mirror.displayStyle)
            mirror.children.forEach { (child) in
                print(child)
            }
            print("error: actualValue: `\(resultObject)`, having type: `\(type(of: resultObject))`, expectedType: `\(Response.self)`")
            throw Error.cast(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
