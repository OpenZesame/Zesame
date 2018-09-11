//
//  DefaultZilliqaService.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-09-10.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxSwift
import JSONRPCKit
import APIKit

public typealias ZilliqaServiceReactive = ZilliqaService & ReactiveCompatible
public final class DefaultZilliqaService: ZilliqaServiceReactive {

    public let wallet: Wallet

    public let apiClient: APIClient = JsonRpcClient()

    public init(wallet: Wallet) {
        self.wallet = wallet
    }
}

public protocol APIClient {
    func send<Request, Response>(request: Request, done: @escaping RequestDone<Response>)
        where
        Request: JSONRPCKit.Request,
        Response: Decodable,
        /* This should hopefully be removed soon  */
        Request.Response == Dictionary<String, Any>
}

public final class JsonRpcClient: APIClient {

    private let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())

    public init() {}
}

public extension DefaultZilliqaService {
    func getBalalance(done: @escaping RequestDone<BalanceResponse>) -> Void {
        return apiClient.send(request: BalanceRequest(publicAddress: wallet.address.address), done: done)
    }


    func send(transaction: Transaction, done: @escaping RequestDone<TransactionResponse>) {
        return apiClient.send(request: TransactionRequest(transaction: transaction), done: done)
    }
}

// MARK: - DefaultZilliqaService APIKit
public extension JsonRpcClient {
    func send<Request, Response>(request: Request, done: @escaping RequestDone<Response>)
        where
        Request: JSONRPCKit.Request,
        Response: Decodable,
        /* This should hopefully be removed soon  */
        Request.Response == Dictionary<String, Any>
    {
        let batch = batchFactory.create(request)
        let httpRequest = ZilliqaRequest(batch: batch)
        let handlerAPIKit = mapHandler(done)

        let _: SessionTask? = Session.send(httpRequest, callbackQueue: nil) { result in
            switch result {
            case .success(let response):
                let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
                let model = try! JSONDecoder().decode(Response.self, from: jsonData)
                handlerAPIKit(.success(model))
            case .failure(let error):
                handlerAPIKit(.failure(error))
            }
        }
    }
}
