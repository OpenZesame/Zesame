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

public typealias TransactionIdentifier = String

public protocol ZilliqaService {

    var wallet: Wallet { get }
    var apiClient: APIClient { get }

    func getBalalance(done: @escaping RequestDone<BalanceResponse>)

    func send(transaction: Transaction, done: @escaping RequestDone<TransactionIdentifier>)
}

public extension ZilliqaService {
    
    func signAndMakeTransaction(payment: Payment, using keyPair: KeyPair, done: @escaping RequestDone<TransactionIdentifier>) {
        let transaction = sign(payment: payment, using: keyPair)
        send(transaction: transaction, done: done)
    }

    func sign(payment: Payment, using keyPair: KeyPair) -> Transaction {

        let unsignedTransaction = UnsignedTransaction(payment: payment)

        let message = messageFromUnsignedTransaction(unsignedTransaction, publicKey: keyPair.publicKey)

        let signature = sign(message: message, using: keyPair)

        assert(Signer.verify(message, wasSignedBy: signature, publicKey: keyPair.publicKey))

        return Transaction(unsignedTransaction: unsignedTransaction, signedBy: keyPair.publicKey, signature: signature)
    }

    func sign(message: Message, using keyPair: KeyPair) -> Signature {
        return Signer.sign(message, using: keyPair)
    }
}
