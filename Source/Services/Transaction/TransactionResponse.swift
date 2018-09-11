//
//  TransactionResponse.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-09-10.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct TransactionResponse: Decodable {
    public enum CodingKeys: String, CodingKey {
        case transactionId = "result"
    }

    /// `1`
    /// probably dont need to parse this
    /// this is probably some versioning of the API or an identifier for the testnet
//    let id: Int

//    /// `"2.0"`
    /// probably dont need to parse this
//    let jsonrpc: String

    /// E.g. `"ad28f2c63ba118134b45496454c0f1db05c214894848eab929381dbeeff91872"`
    public let transactionId: String

}
