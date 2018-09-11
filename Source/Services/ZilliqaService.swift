//
//  ZilliqaService.swift
//  ZilliqaSDK iOS
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import EllipticCurveKit
import JSONRPCKit
import Result
import APIKit
import RxCocoa
import RxSwift

public protocol ZilliqaService {
    var wallet: Wallet { get }
    var apiClient: APIClient { get }
    func getBalalance(done: @escaping RequestDone<BalanceResponse>)
    func send(transaction: Transaction, done: @escaping RequestDone<TransactionResponse>)
}

public extension ZilliqaService {
    func signAndMakeTransaction(payment: Payment, using keyPair: KeyPair, done: @escaping RequestDone<TransactionResponse>) {
        let transaction = sign(payment: payment, using: keyPair)
        send(transaction: transaction, done: done)
    }

    func sign(payment: Payment, using keyPair: KeyPair) -> Transaction {

        let unsignedTransaction = UnsignedTransaction(payment: payment)

        let message = messageFromUnsignedTransaction(unsignedTransaction)

        let signature = Signer.sign(message, using: keyPair)

        return Transaction(unsignedTransaction: unsignedTransaction, signedBy: keyPair.publicKey, signature: signature)
    }
}



/*
 How Zilliqa web does it
 https://github.com/Zilliqa/Zilliqa-JavaScript-Library/blob/master/src/util.ts#L115-L139

 /**
 * encodeTransaction
 *
 * @param {any} txn
 * @returns {Buffer}
 */
 export const encodeTransaction = (txn: TxDetails) => {
 let codeHex = new Buffer(txn.code).toString('hex');
 let dataHex = new Buffer(txn.data).toString('hex');

 let encoded =
 intToByteArray(txn.version, 64).join('') +
 intToByteArray(txn.nonce, 64).join('') +
 txn.to +
 txn.pubKey +
 txn.amount.toString('hex', 64) +
 intToByteArray(txn.gasPrice, 64).join('') +
 intToByteArray(txn.gasLimit, 64).join('') +
 intToByteArray(txn.code.length, 8).join('') + // size of code
 codeHex +
 intToByteArray(txn.data.length, 8).join('') + // size of data
 dataHex;

 return new Buffer(encoded, 'hex');
 };
 */
func messageFromUnsignedTransaction(_ transaction: UnsignedTransaction) -> Message {
    fatalError()
}
