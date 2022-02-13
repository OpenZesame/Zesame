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

import XCTest
@testable import Zesame
import CryptoSwift

import EllipticCurveKit


typealias PrivateKey = EllipticCurveKit.PrivateKey<Curve>

private let privateKey = PrivateKey(hex: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638")!
private let password = "apabanan"

public extension KDFParams {
    
    static var quickTestParameters: Self {
        do {
            return try Self(
                costParameterN: 2,
                costParameterC: 2
            )
        } catch {
            fatalError("Incorrect implementation, should always be able to create default KDF params, unexpected error: \(error)")
        }
    }
}

extension Keystore {
    static func with(
        kdf: KDF,
        kdfParams: KDFParams = .quickTestParameters
    ) async -> Keystore {
        try! await Keystore.from(
            privateKey: privateKey,
            encryptBy: password,
            kdf: kdf,
            kdfParams: kdfParams
        )
    }

    func decryptPrivateKey() async -> PrivateKey? {
        await decryptPrivateKey(password: password)
    }

    func decryptPrivateKey(password: String) async -> PrivateKey? {
        do {
            return try await decryptPrivateKeyWith(password: password)
        } catch {
            XCTFail("unexpected error: \(error)")
            return nil
        }
        
    }
}


class ScryptTests: XCTestCase {
    
    func testScrypt() async throws {
        let keystore =  await Keystore.with(kdf: .scrypt)
        let decryptedPrivateKey =  await keystore.decryptPrivateKey()
        XCTAssertEqual(decryptedPrivateKey, privateKey)
    }
    
    func testPbkdf2() async throws {
        let keystore = await Keystore.with(kdf: .pbkdf2)
        let decryptedPrivateKey = await keystore.decryptPrivateKey()
        XCTAssertEqual(decryptedPrivateKey, privateKey)
    }
    
    
    typealias JSON = [String: Any]
    
    func testNewWalletKeystore() async throws {
        let privateKey = PrivateKey.generateNew()
        let password = "apabanan"
        
        let keystore = try! await Keystore.from(privateKey: privateKey, encryptBy: password, kdf: .scrypt)
        XCTAssertEqual(keystore.crypto.keyDerivationFunctionParameters.saltHex.count, 64)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(keystore)
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! JSON
        let crypto = json["crypto"] as! JSON
        let kdfparams = crypto["kdfparams"] as! JSON
        let salt = kdfparams["salt"] as! String
        XCTAssertNotNil(try? HexString(salt))
        
    }
}
