// 
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
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
import CryptoKit
import EllipticCurveKit

public extension ZilliqaService {

    func sendTransaction(
        for payment: Payment,
        keystore: Keystore,
        password: String,
        network: Network
    ) async throws -> TransactionResponse {
        let keyPair = try await keystore.toKeypair(encryptedBy: password)
        return try await sendTransaction(for: payment, signWith: keyPair, network: network)
    }

    func sendTransaction(
        for payment: Payment,
        signWith keyPair: KeyPair,
        network: Network
    ) async throws -> TransactionResponse {
        let transaction = sign(
            payment: payment,
            using: keyPair,
            network: network
        )
        return try await send(transaction: transaction)
    }

    func sign(
        payment: Payment,
        using keyPair: KeyPair,
        network: Network
    ) -> SignedTransaction {

        let transaction = Transaction(payment: payment, version: Version(network: network))

        let message = messageFromUnsignedTransaction(transaction, publicKey: keyPair.publicKey, hasher: SHA256())

        let signature = sign(message: message, using: keyPair)

        assert(Signer.verify(message, wasSignedBy: signature, publicKey: keyPair.publicKey))

        return SignedTransaction(transaction: transaction, signedBy: keyPair.publicKey, signature: signature)
    }

    func sign(message: Message, using keyPair: KeyPair) -> Signature {
        Signer.sign(message, using: keyPair, personalizationDRBG: drbgPers)
    }
}

private let drbgPers: Data = {
    let pers = "Schnorr+SHA256  ".data(using: .ascii)!
    var returnValue = Data([Byte](repeating: 0x00, count: 32))
    returnValue = returnValue + pers
    if returnValue.count != 48 { fatalError("bad length") }
    return returnValue
}()
