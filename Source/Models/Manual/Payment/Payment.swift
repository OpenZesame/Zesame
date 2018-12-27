//
//  Payment.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Payment {
    public let recipient: Address
    public let amount: ZilAmount
    public let gasLimit: GasLimit
    public let gasPrice: GasPrice
    public let nonce: Nonce

    public init(
        to recipient: Address,
        amount: ZilAmount,
        gasLimit: GasLimit = .defaultGasLimit,
        gasPrice: GasPrice,
        nonce: Nonce = 0
        ) {
        self.recipient = recipient
        self.amount = amount
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.nonce = nonce.increasedByOne()
    }
}


public extension Payment {
    static func estimatedTotalTransactionFee(gasPrice: GasPrice, gasLimit: GasLimit = .defaultGasLimit) -> Qa {
        return (gasLimit * gasPrice).inQa
    }

    static func estimatedTotalCostOfTransaction(amount: ZilAmount, gasPrice: GasPrice, gasLimit: GasLimit = .defaultGasLimit) throws -> ZilAmount {

        let fee = estimatedTotalTransactionFee(gasPrice: gasPrice, gasLimit: gasLimit)
        let amountInQa = amount.inQa
        let totalInQaAsSignificand: Qa.Significand = amountInQa.significand + fee.significand

        let totalSupplyInQaAsSignificand: Qa.Significand = Zil.totalSupply.inQa.significand

//        print("fee: \(fee)")
//        print("total: \(totalInQa)")
//        print("totalSupply: \(totalSupplyInQa)")

        let tooLargeError = AmountError.tooLarge(maxSignificandIs: Zil.maxSignificand)

        guard totalInQaAsSignificand < totalSupplyInQaAsSignificand else {
            throw tooLargeError
        }

        // Ugly trick to handle problem of small fees and big amounts.
        // When adding 1E-12 to 21E9 the `Double` rounds down to
        // 21E9 so we lose the 1E-12 part. Thus we subtract 21E9
        // to be able to keep the 1E-12 part and compare it against
        // the transaction cost. Ugly, but it works...
        if totalInQaAsSignificand == totalSupplyInQaAsSignificand {
            print("totalInZil == totalSupplyInZil")
            let subtractedTotalSupplyFromAmount = totalInQaAsSignificand - totalSupplyInQaAsSignificand
            if (subtractedTotalSupplyFromAmount + fee.significand) != fee.significand {
                throw tooLargeError
            }
        } else {
            print("totalInZil != totalSupplyInZil")
        }

        return try ZilAmount(qa: Qa(totalInQaAsSignificand))
    }
}
