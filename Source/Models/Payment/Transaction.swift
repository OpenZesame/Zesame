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

        case to, amount, gasPrice, gasLimit, nonce, signature, version
    }

    public let version: Int

    public let nonce: Int

    /// The public address of the recipient as a hex string
    /// E.g. "0xF510333720C5DD3C3C08BC8E085E8C981CE74691"
    public let to: String

    public let amount: Double

    public let publicKeyCompressed: String

    public let gasPrice: Double

    public let gasLimit: Double

    public let code: String

    public let data: String

    public let signature: String

    public init(
        version: Int = 0,
        nonce: Int,
        to: String,
        amount: Double,
        publicKeyCompressed: String,
        gasPrice: Double = 1,
        gasLimit: Double = 10,
        code: String = "",
        data: String = "",
        signature: String
        ) {
        self.version = version
        self.nonce = nonce
        self.to = to
        self.amount = amount
        self.publicKeyCompressed = publicKeyCompressed
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.code = code
        self.data = data
        self.signature = signature
    }

}

import EllipticCurveKit

public extension Transaction {
    init(unsignedTransaction tx: UnsignedTransaction, signedBy publicKey: PublicKey, signature: Signature) {
        self.init(
            version: tx.version,
            nonce: tx.nonce,
            to: tx.to,
            amount: tx.amount,
            publicKeyCompressed: publicKey.data.compressed.toHexString(),
            gasPrice: tx.gasPrice,
            gasLimit: tx.gasLimit,
            signature: signature.asHexString()
        )
    }
}
