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

        let message = messageFromUnsignedTransaction(unsignedTransaction, publicKey: keyPair.publicKey)

        let signature = sign(message: message, using: keyPair)

        print("signature: `\(signature)`")

        return Transaction(unsignedTransaction: unsignedTransaction, signedBy: keyPair.publicKey, signature: signature)
    }

    func sign(message: Message, using keyPair: KeyPair) -> Signature {
        return Signer.sign(message, using: keyPair)
    }
}

extension String {
    enum Case {
        case lower, upper
    }
    func `case`(_ `case`: Case) -> String {
        switch `case` {
        case .lower: return lowercased()
        case .upper: return uppercased()
        }
    }
}

func messageFromUnsignedTransaction(_ tx: UnsignedTransaction, publicKey: PublicKey) -> Message {
        func hex64B(_ number: BigNumber) -> String {
            let hex = number.asHexStringLength64()//.case(`case`)
            assert(hex.count == 64)
            return hex
        }
        func hex64D(_ number: Double) -> String {
            return hex64B(BigNumber(number))
        }
        func hex64I(_ number: Int) -> String {
            return hex64D(Double(number))
        }

    func eightChar(from int: Int) -> String {
        return String(format: "%08d", int)
    }

    func formatCodeOrData(from string: String) -> String {
        if let data = string.data(using: .utf8) {
            return data.toHexString()
        } else {
            print("Failed to create Swift.Data from `code` or `data` having value: \n`\(string)`")
            return ""
        }
    }

    let codeHex = formatCodeOrData(from: tx.code)
    let dataHex = formatCodeOrData(from: tx.data)

        let hexString = [
            hex64I(tx.version),
            hex64I(tx.nonce),
            tx.to.case(.upper),
            publicKey.hex.compressed.case(.lower),
            hex64D(tx.amount).case(.lower),
            hex64D(tx.gasPrice),
            hex64D(tx.gasLimit),
            eightChar(from: tx.code.count),
            codeHex,
            eightChar(from: tx.data.count),
            dataHex,
            ].joined()
    return Message(hex: hexString)
}
