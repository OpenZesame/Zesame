//
//  StatusOfTransactionRequest.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-11.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct StatusOfTransactionResponse: Decodable {
    public struct Receipt {
        public let totalGasCost: Amount
        public let isSent: Bool
    }

    public let receipt: Receipt
}

extension StatusOfTransactionResponse.Receipt: Decodable {}
public extension StatusOfTransactionResponse.Receipt {

    enum CodingKeys: String, CodingKey {
        case totalGasCost = "cumulative_gas"
        case isSent = "success"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let costAsString = try container.decode(String.self, forKey: .totalGasCost)
        self.totalGasCost = try Amount(string: costAsString)
        self.isSent = try container.decode(Bool.self, forKey: .isSent)
    }
}

public struct StatusOfTransactionRequest: JSONRPCKit.Request {
    public typealias Response = StatusOfTransactionResponse

    public let transactionId: String
    public init(transactionId: String) {
        self.transactionId = transactionId
    }
}

public extension StatusOfTransactionRequest {
    var method: String {
        return "GetTransaction"
    }

    var parameters: Encodable? {
        return [transactionId]
    }
}
