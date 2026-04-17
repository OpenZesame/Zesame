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

import CryptoKit
import Foundation

public extension ZilliqaService {
    func sendTransaction(
        for payment: Payment,
        keystore: Keystore,
        password: String,
        network: Network
    ) async throws -> TransactionResponse {
        let keyPair = try keystore.toKeypair(encryptedBy: password)
        return try await sendTransaction(for: payment, signWith: keyPair, network: network)
    }

    func sendTransaction(
        for payment: Payment,
        signWith keyPair: KeyPair,
        network: Network
    ) async throws -> TransactionResponse {
        try await send(transaction: try sign(payment: payment, using: keyPair, network: network))
    }

    func sign(
        payment: Payment,
        using keyPair: KeyPair,
        network: Network
    ) throws -> SignedTransaction {
        let transaction = Transaction(payment: payment, version: Version(network: network))
        let messageData = try messageFromUnsignedTransaction(transaction, publicKey: keyPair.publicKey, hasher: SHA256())
        let signature = try sign(message: messageData, using: keyPair)

        assert(keyPair.publicKey.isValidSignature(signature, hashed: messageData))

        return SignedTransaction(transaction: transaction, signedBy: keyPair.publicKey, signature: signature)
    }

    func sign(message: Data, using keyPair: KeyPair) throws -> Signature {
        try keyPair.privateKey.signature(for: message)
    }
}
