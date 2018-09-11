//
//  Transaction.swift
//  ZilliqaSDK iOS
//
//  Created by Alexander Cyon on 2018-09-10.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Transaction: Encodable {
    public enum CodingKeys: String, CodingKey {
        case publicKeyCompressed = "pubKey"
        case recipientAddressHex = "to"

        case amount, gasPrice, gasLimit, nonce, signature, version
    }

    public let amount: Double

    public let gasPrice: Double
    public let gasLimit: Double
    public let nonce: Int

    public let publicKeyCompressed: String

    public let signature: String

    /// E.g. "0xF510333720C5DD3C3C08BC8E085E8C981CE74691"
    public let recipientAddressHex: String

    public let version: Int

    public init(
        amount: Double,
        gasPrice: Double = 1,
        gasLimit: Double = 10,
        nonce: Int,
        publicKeyCompressed: String,
        signature: String,
        recipientAddressHex: String,
        version: Int = 0
        ) {
        self.amount = amount
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.nonce = nonce
        self.publicKeyCompressed = publicKeyCompressed
        self.signature = signature
        self.recipientAddressHex = recipientAddressHex
        self.version = version
    }
//
//    /// Smart contract support in the future
//    public let code: String
//    /// Smart contract support in the future
//    public let data: String
}

import EllipticCurveKit

public extension Transaction {
    init(unsignedTransaction tx: UnsignedTransaction, signedBy publicKey: PublicKey, signature: Signature) {
        self.init(
            amount: tx.amount,
            gasPrice: tx.gasPrice,
            gasLimit: tx.gasLimit,
            nonce: tx.nonce,
            publicKeyCompressed: publicKey.data.compressed.toHexString(),
            signature: signature.asHexString(),
            recipientAddressHex: tx.to,
            version: tx.version)
    }
}
