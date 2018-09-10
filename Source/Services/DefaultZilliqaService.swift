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

    private let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())

    public init(wallet: Wallet) {
        self.wallet = wallet
    }
}

public extension DefaultZilliqaService {
    func getBalalance(_ done: @escaping RequestDone<BalanceResponse>) -> Void {
        return send(request: BalanceRequest(publicAddress: wallet.address.address), done: done)
    }
}

// MARK: - DefaultZilliqaService APIKit
public extension DefaultZilliqaService {
    func send<Request, Response>(request: Request, done: @escaping RequestDone<Response>)
        where Request: JSONRPCKit.Request,
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
