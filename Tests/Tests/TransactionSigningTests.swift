//
//  TransactionSigningTests.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-09-11.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import XCTest
import EllipticCurveKit
@testable import Zesame

// Some uninteresting Zilliqa TESTNET private key, containing worthless TEST tokens.
private let privateKeyHex = "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"
private let service = DefaultZilliqaService.shared

class TransactionSigningTests: XCTestCase {

    func testTransactionSigning() {

        let privateKey = PrivateKey(hex: privateKeyHex)!
        let publicKey = PublicKey(privateKey: privateKey)
        let keyPair = KeyPair(privateKeyHex: privateKeyHex)!
        let recipient = try! Address(string: "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039")

        let payment = Payment(
            to: recipient,
            amount: 15,
            gasLimit: 1,
            gasPrice: GasPrice.min,
            nonce: Nonce(3)
        )

        let unsignedTx = Transaction(payment: payment)

        XCTAssertEqual(unsignedTx.payment.amount, 15)
        XCTAssertEqual(unsignedTx.payment.gasLimit, 1)
        XCTAssertEqual(unsignedTx.payment.gasPrice, 1_000_000_000)
        XCTAssertEqual(unsignedTx.payment.nonce, 4)
        XCTAssertEqual(unsignedTx.version, 65537)
        XCTAssertTrue(unsignedTx.payment.recipient.asString == "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039")

        let message = messageFromUnsignedTransaction(unsignedTx, publicKey: publicKey)
        let signature = service.sign(message: message, using: keyPair)

        let signedTransaction = SignedTransaction(transaction: unsignedTx, signedBy: publicKey, signature: signature)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let transactionJSONData = try jsonEncoder.encode(signedTransaction)
            let transactionJSONString = String(data: transactionJSONData, encoding: .utf8)!
            XCTAssertEqual(transactionJSONString, expectedTransactionJSONString)
        } catch {
            return XCTFail("Should not throw, unexpected error: \(error)")
        }
    }
}

private let expectedTransactionJSONString = """
{
  "amount" : "15000000000000",
  "toAddr" : "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039",
  "pubKey" : "034AE47910D58B9BDE819C3CFFA8DE4441955508DB00AA2540DB8E6BF6E99ABC1B",
  "data" : "",
  "code" : "",
  "signature" : "349A9085A4F4455B7F334A42D8C7DE552A377093BC55FDA20EBF7ADA9FDCFB92108A5956B16FD2334F6D83201E7B999164223765A3DDCBAFC69D215922DC1F80",
  "gasLimit" : "1",
  "version" : 65537,
  "gasPrice" : "1000000000",
  "nonce" : 4
}
"""
