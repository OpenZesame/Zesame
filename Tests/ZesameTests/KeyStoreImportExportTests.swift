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
import Testing
@testable import Zesame

private let privateKey =
    try! PrivateKey(rawRepresentation: Data(hex: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"))
private let password = "apabanan"

public extension KDFParams {
    static var quickTestParameters: Self {
        do {
            return try Self(iterations: 1)
        } catch {
            fatalError(
                "Incorrect implementation, should always be able to create test KDF params, unexpected error: \(error)"
            )
        }
    }
}

extension Keystore {
    static func makeTest(kdfParams: KDFParams = .quickTestParameters) throws -> Keystore {
        try Keystore.from(
            privateKey: privateKey,
            encryptBy: password,
            kdf: .pbkdf2,
            kdfParams: kdfParams
        )
    }
}

@Suite struct KeystoreTests {
    @Test func pbkdf2AES256GCM() throws {
        let keystore = try Keystore.makeTest()
        let decryptedPrivateKey = try keystore.decryptPrivateKey(encryptedBy: password)
        #expect(decryptedPrivateKey == privateKey)
    }

    @Test func newWalletKeystore() throws {
        typealias JSON = [String: Any]
        let newPrivateKey = PrivateKey()
        let keystore = try Keystore.from(
            privateKey: newPrivateKey,
            encryptBy: password,
            kdf: .pbkdf2,
            kdfParams: .quickTestParameters
        )
        #expect(keystore.version == 4)
        #expect(keystore.crypto.keyDerivationFunctionParameters.saltHex.count == 64)
        #expect(keystore.crypto.cipherParameters.nonceHex.count == 24)
        #expect(keystore.crypto.cipherParameters.tagHex.count == 32)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(keystore)
        let json = try #require(try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON)
        let crypto = try #require(json["crypto"] as? JSON)
        #expect(crypto["cipher"] as? String == "aes-256-gcm")
        let kdfparams = try #require(crypto["kdfparams"] as? JSON)
        #expect(kdfparams["prf"] as? String == "hmac-sha512")
        let salt = try #require(kdfparams["salt"] as? String)
        #expect((try? HexString(salt)) != nil)
        let cipherparams = try #require(crypto["cipherparams"] as? JSON)
        #expect(cipherparams["nonce"] is String)
        #expect(cipherparams["tag"] is String)
    }
}
