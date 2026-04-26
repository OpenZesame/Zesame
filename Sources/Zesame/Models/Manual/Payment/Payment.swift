//
// MIT License
//
// Copyright (c) 2018-2026 Open Zesame (https://github.com/OpenZesame)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

/// User-facing description of a transfer: recipient, amount, gas, and nonce.
///
/// The nonce supplied at construction time is the *current* on-chain nonce; ``Payment`` stores
/// `nonce + 1`, which is what the network expects for the next transaction.
public struct Payment {
    /// Receiver of the transfer.
    public let recipient: LegacyAddress
    /// Amount of Zil to send.
    public let amount: Amount
    /// Gas units the sender is willing to spend.
    public let gasLimit: GasLimit
    /// Price per gas unit (in Qa).
    public let gasPrice: GasPrice
    /// Transaction nonce, already incremented to the value the network expects.
    public let nonce: Nonce

    /// Validates the gas limit and pre-increments the nonce.
    ///
    /// `nonce` is the **current** on-chain nonce (the value `GetBalance` returns); the stored
    /// nonce is `nonce + 1`, which is what the network expects for the next transaction. If you
    /// already know the exact next nonce, use ``init(to:amount:gasLimit:gasPrice:nextNonce:)``
    /// instead — implicit increment is a footgun that's caused off-by-one errors in the past.
    ///
    /// - Throws: ``Payment/Error/gasLimitTooLow`` when `gasLimit < GasLimit.minimum`.
    public init(
        to recipient: LegacyAddress,
        amount: Amount,
        gasLimit: GasLimit = .defaultGasLimit,
        gasPrice: GasPrice,
        nonce: Nonce = 0
    ) throws {
        try self.init(
            to: recipient,
            amount: amount,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            nextNonce: nonce.increasedByOne()
        )
    }

    /// Like ``init(to:amount:gasLimit:gasPrice:nonce:)`` but takes the **exact** nonce to embed
    /// in the transaction. No implicit increment — passing `nextNonce: 5` produces a transaction
    /// signed with `nonce = 5`. Prefer this overload when the nonce is already known.
    ///
    /// - Throws: ``Payment/Error/gasLimitTooLow`` when `gasLimit < GasLimit.minimum`.
    public init(
        to recipient: LegacyAddress,
        amount: Amount,
        gasLimit: GasLimit = .defaultGasLimit,
        gasPrice: GasPrice,
        nextNonce: Nonce
    ) throws {
        guard gasLimit >= GasLimit.minimum
        else { throw Error.gasLimitTooLow(got: gasLimit, butMinIs: GasLimit.minimum) }
        self.recipient = recipient
        self.amount = amount
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        nonce = nextNonce
    }

    /// Construction-time validation errors.
    enum Error: Swift.Error {
        /// The supplied gas limit is below the network minimum.
        case gasLimitTooLow(got: GasLimit, butMinIs: GasLimit)
    }
}

public extension Payment {
    /// Convenience constructor pinning ``gasLimit`` to ``GasLimit/minimum`` — the cheapest payment
    /// the network will accept. Force-tries because the only way this can throw is gas-limit
    /// validation, which is satisfied by construction here.
    static func withMinimumGasLimit(
        to recipient: LegacyAddress,
        amount: Amount,
        gasPrice: GasPrice,
        nonce: Nonce = 0
    ) -> Self {
        try! .init(to: recipient, amount: amount, gasLimit: GasLimit.minimum, gasPrice: gasPrice, nonce: nonce)
    }

    /// Total fee budget for a transaction in Qa: `gasLimit × gasPrice`.
    static func estimatedTotalTransactionFee(
        gasPrice: GasPrice,
        gasLimit: GasLimit = .defaultGasLimit
    ) throws -> Qa {
        Qa(qa: Qa.Magnitude(gasLimit) * gasPrice.qa)
    }

    /// Sum of `amount` and the estimated transaction fee, validated against total supply.
    ///
    /// - Throws: ``AmountError/tooLarge`` if the result would exceed ``Amount/max``.
    static func estimatedTotalCostOfTransaction(
        amount: Amount,
        gasPrice: GasPrice,
        gasLimit: GasLimit = .defaultGasLimit
    ) throws -> Amount {
        let fee = try estimatedTotalTransactionFee(gasPrice: gasPrice, gasLimit: gasLimit)
        let amountInQa = amount.asQa
        let totalInQa: Qa = amountInQa + fee

        let tooLargeError = AmountError.tooLarge(max: Amount.max)

        guard totalInQa < Amount.max.asQa else {
            throw tooLargeError
        }

        // Ugly trick to handle problem of small fees and big amounts.
        // When adding 1E-12 to 21E9 the `Double` rounds down to
        // 21E9 so we lose the 1E-12 part. Thus we subtract 21E9
        // to be able to keep the 1E-12 part and compare it against
        // the transaction cost. Ugly, but it works...
        if totalInQa == Amount.max.asQa {
            let subtractedTotalSupplyFromAmount = totalInQa - Amount.max.asQa
            if (subtractedTotalSupplyFromAmount + fee) != fee {
                throw tooLargeError
            }
        }
        return try Amount(qa: totalInQa)
    }
}
