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

        let recipient = try! Address(hexString: "9CA91EB535FB92FDA5094110FDAEB752EDB9B039")

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
        XCTAssertEqual(unsignedTx.payment.recipient, "9cA91eB535fb92FDA5094110fDAeb752EdB9B039")

        let message = messageFromUnsignedTransaction(unsignedTx, publicKey: publicKey)
        let signature = service.sign(message: message, using: keyPair)

        let expectedSignature = "349A9085A4F4455B7F334A42D8C7DE552A377093BC55FDA20EBF7ADA9FDCFB92108A5956B16FD2334F6D83201E7B999164223765A3DDCBAFC69D215922DC1F80"

        XCTAssertEqual(signature.asHexString(), expectedSignature)

        func signatureForManipulatedMessage(onlyUppercased shouldUppercase: Bool) -> String {
            let msg = message.description
            let manipulatedRaw = shouldUppercase ? msg.uppercased() : msg.lowercased()
            let manipulated = Message(hashedHex: manipulatedRaw, hashedBy: EllipticCurveKit.DefaultHasher.sha256)!
            return service.sign(message: manipulated, using: keyPair).asHexString()
        }

        XCTAssertEqual(signatureForManipulatedMessage(onlyUppercased: true), expectedSignature)
        XCTAssertEqual(signatureForManipulatedMessage(onlyUppercased: false), expectedSignature)
    }
}
