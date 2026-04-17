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
import XCTest
@testable import Zesame

class ExportKeystoreTest: XCTestCase {

    func testWalletImport() {
        let service = DefaultZilliqaService(endpoint: .testnet)
        let expectWalletImport = expectation(description: "importing wallet from keystore")
        do {
            let keyRestoration = KeyRestoration.privateKey(knownPrivateKey, encryptBy: password, kdf: .pbkdf2)
            service.restoreWallet(from: keyRestoration) {
                switch $0 {
                case .success(let importedWallet):
                    XCTAssertEqual(importedWallet.keystore.address.asString, expectedAddress)
                    XCTAssertEqual(importedWallet.keystore.version, 4)
                case .failure(let error): XCTFail("Failed to import wallet, error: \(error)")
                }
                expectWalletImport.fulfill()
            }
            waitForExpectations(timeout: 5, handler: nil)
        }
    }

    func testKeystoreEncodeDecode() {
        let expectRoundtrip = expectation(description: "keystore encode/decode roundtrip")
        try! Keystore.from(
            privateKey: knownPrivateKey,
            encryptBy: password,
            kdf: .pbkdf2,
            kdfParams: .quickTestParameters
        ) { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed to create keystore, error: \(error)")
                expectRoundtrip.fulfill()
            case .success(let keystore):
                XCTAssertEqual(keystore.address.asString, expectedAddress)
                do {
                    let jsonData = try JSONEncoder().encode(keystore)
                    let decoded = try JSONDecoder().decode(Keystore.self, from: jsonData)
                    XCTAssertEqual(decoded.address.asString, expectedAddress)
                    XCTAssertEqual(decoded.version, 4)
                    decoded.decryptPrivateKeyWith(password: password) { decryptResult in
                        switch decryptResult {
                        case .failure(let error):
                            XCTFail("Failed to decrypt, error: \(error)")
                        case .success(let key):
                            XCTAssertEqual(key.rawRepresentation.asHex.uppercased(), expectedPrivateKey.uppercased())
                        }
                        expectRoundtrip.fulfill()
                    }
                } catch {
                    XCTFail("Encode/decode failed: \(error)")
                    expectRoundtrip.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

private let password = "apabanan"
private let expectedPrivateKey = "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"
private let expectedAddress = "74c544a11795905C2c9808F9e78d8156159d32e4"
private let knownPrivateKey = try! PrivateKey(rawRepresentation: Data(hex: expectedPrivateKey))
