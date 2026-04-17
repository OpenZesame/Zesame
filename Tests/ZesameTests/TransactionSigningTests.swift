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
import Testing
@testable import Zesame

private let network: Network = .mainnet
private let service = DefaultZilliqaService(endpoint: .testnet)

@Suite struct TransactionSigningTests {
    @Test func transactionSigning() throws {
        // Some uninteresting Zilliqa TESTNET private key, that might contain some worthless TEST tokens.
        let privateKey = try PrivateKey(
            rawRepresentation: Data(hex: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638")
        )
        let publicKey = privateKey.publicKey

        let unsignedTx = try Transaction(
            payment: Payment.withMinimumGasLimit(
                to: LegacyAddress(string: "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039"),
                amount: 15,
                gasPrice: GasPrice.min,
                nonce: Nonce(3)
            ),
            version: Version(network: network)
        )

        let message = messageFromUnsignedTransaction(unsignedTx, publicKey: publicKey, hasher: SHA256())
        let signature = service.sign(message: message, using: KeyPair(private: privateKey))

        let signedTransaction = SignedTransaction(transaction: unsignedTx, signedBy: publicKey, signature: signature)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let transactionJSONData = try jsonEncoder.encode(signedTransaction)
        let json = try #require(try JSONSerialization.jsonObject(with: transactionJSONData) as? [String: Any])

        #expect(json["pubKey"] as? String == expectedPubKey)
        #expect(json["toAddr"] as? String == "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039")
        #expect(json["amount"] as? String == "15000000000000")
        #expect(json["gasPrice"] as? String == "100000000000")
        #expect(json["gasLimit"] as? String == "50")
        #expect(json["version"] as? Int == 65537)
        #expect(json["nonce"] as? Int == 4)
        let sig = json["signature"] as? String
        #expect(sig?.count == 128, "BIP340 Schnorr signature should be 64 bytes (128 hex chars)")
    }
}

private let expectedPubKey = "034AE47910D58B9BDE819C3CFFA8DE4441955508DB00AA2540DB8E6BF6E99ABC1B"
