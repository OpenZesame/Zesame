//
//  Payment.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Payment {
    public let recipient: Recipient
    public let amount: Double
    public let gasLimit: Double
    public let gasPrice: Double
    public let nonce: Int

    public init?(
        to recipient: Recipient,
        amount: Double,
        gasLimit: Double = 10,
        gasPrice: Double = 1,
        from wallet: Wallet) {
        guard
            amount > 0,
            gasLimit > 10,
            gasPrice > 0,
            amount + gasLimit > wallet.balance.amount
            else { return nil }
        self.recipient = recipient
        self.amount = amount
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.nonce = wallet.nonce.nonce + 1
    }
}


public struct UnsignedTransaction: Encodable {
    let version: Int
    let nonce: Int
    let to: String
    let amount: Double
    let gasPrice: Double
    let gasLimit: Double

    init(payment: Payment, version: Int = 0) {
        self.to = payment.recipient.address
        self.amount = payment.amount
        self.gasPrice = payment.gasPrice
        self.gasLimit = payment.gasLimit
        self.nonce = payment.nonce
        self.version = version
    }
}
