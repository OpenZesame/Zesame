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

import CryptoKit
import Foundation

public extension ZilliqaService {
    /// Decrypts the keystore with `password`, then signs and broadcasts the payment.
    func sendTransaction(
        for payment: Payment,
        keystore: Keystore,
        password: String,
        network: Network
    ) async throws -> TransactionResponse {
        let keyPair = try keystore.toKeypair(encryptedBy: password)
        return try await sendTransaction(for: payment, signWith: keyPair, network: network)
    }

    /// Signs `payment` with `keyPair` and broadcasts the resulting transaction.
    func sendTransaction(
        for payment: Payment,
        signWith keyPair: KeyPair,
        network: Network
    ) async throws -> TransactionResponse {
        try await send(transaction: sign(payment: payment, using: keyPair, network: network))
    }

    /// Builds the canonical protobuf message for `payment`, signs its SHA-256 digest with the
    /// private key, and returns a ``SignedTransaction`` ready for broadcast.
    ///
    /// The function asserts that the produced signature verifies against the public key — a
    /// programmer-error tripwire, not a runtime check.
    func sign(
        payment: Payment,
        using keyPair: KeyPair,
        network: Network
    ) throws -> SignedTransaction {
        let transaction = Transaction(payment: payment, version: Version(network: network))
        let messageData = try messageFromUnsignedTransaction(
            transaction,
            publicKey: keyPair.publicKey,
            hasher: SHA256()
        )
        let signature = try sign(message: messageData, using: keyPair)

        assert(keyPair.publicKey.isValidSignature(signature, hashed: messageData))

        return SignedTransaction(transaction: transaction, signedBy: keyPair.publicKey, signature: signature)
    }

    /// Signs an arbitrary message digest with the key pair's private key (Schnorr over secp256k1).
    func sign(
        message: Data,
        using keyPair: KeyPair
    ) throws -> Signature {
        try keyPair.privateKey.signature(for: message)
    }
}
