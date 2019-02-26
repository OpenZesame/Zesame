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
import Result
import EllipticCurveKit

extension EllipticCurveKit.PrivateKey: Equatable where Curve == Secp256k1 {
    public static func == (lhs: EllipticCurveKit.PrivateKey<Secp256k1>, rhs: EllipticCurveKit.PrivateKey<Secp256k1>) -> Bool {
        return lhs.asHex() == rhs.asHex()
    }
}

typealias PrivateKey = EllipticCurveKit.PrivateKey<Curve>

private let privateKey = PrivateKey(hex: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638")!
private let password = "apabanan"

extension Keystore {
    static func with(kdf: KDF, done: @escaping (Keystore) -> Void) {
        Keystore.from(
            privateKey: privateKey,
            encryptBy: password,
            kdf: kdf
        ) {
            switch $0 {
            case .failure(let error):
                XCTFail("unexpected error: \(error)")
            case .success(let keyStore):
                done(keyStore)
            }
        }
    }

    func decryptPrivateKey(done: @escaping (PrivateKey) -> Void) {
        decryptPrivateKey(password: password, done: done)
    }

    func decryptPrivateKey(password: String, done: @escaping (PrivateKey) -> Void) {
        decryptPrivateKeyWith(password: password) {
            switch $0 {
            case .failure(let error):
                XCTFail("unexpected error: \(error)")
            case .success(let decryptedPrivateKeyHex):
                let decryptedPrivateKey = PrivateKey(hex: decryptedPrivateKeyHex)!
                done(decryptedPrivateKey)
            }
        }
    }
}


class ScryptTests: XCTestCase {

    func testScrypt() {
        Keystore.with(kdf: .scrypt) { keystore in
            keystore.decryptPrivateKey { decryptedPrivateKey in
                XCTAssertEqual(decryptedPrivateKey, privateKey)
            }
        }
    }

    func testPbkdf2() {
        Keystore.with(kdf: .pbkdf2) { keystore in
            keystore.decryptPrivateKey { decryptedPrivateKey in
                XCTAssertEqual(decryptedPrivateKey, privateKey)
            }
        }
    }
}
