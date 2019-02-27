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
        let expectWalletImport = expectation(description: "importing wallet from keystore json")
        do {
            let keyRestoration = try KeyRestoration(keyStoreJSONString: keystoreWalletJSONString, encryptedBy: password)
            service.restoreWallet(from: keyRestoration) {
                switch $0 {
                case .success(let importedWallet):
                    XCTAssertEqual(importedWallet.keystore.address.asString, "8B6B309E9b910CAf1B40885d3759aE48d239a0F6")

                case .failure(let error): XCTFail("Failed to export, error: \(error)")
                }
                expectWalletImport.fulfill()
            }
            waitForExpectations(timeout: 3, handler: nil)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testKeystoreDecoding() {
        do {
            let json = keystoreWalletJSONString.data(using: .utf8)!
            let keystore = try JSONDecoder().decode(Keystore.self, from: json)
            XCTAssertEqual(keystore.address.asString, "8B6B309E9b910CAf1B40885d3759aE48d239a0F6")

            keystore.decryptPrivateKey(password: password) {
                XCTAssertEqual($0.asHex(), expectedPrivateKey.uppercased())
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}


private let password = "nosnosnos"
private let expectedPrivateKey = "d003230e4ce4e99c226cdb9b4902f30c2578e535bfece708217ba60241cf4165"
private let keystoreWalletJSONString = """
{
	"address": "8b6b309e9b910caf1b40885d3759ae48d239a0f6",
	"crypto": {
		"cipher": "aes-128-ctr",
		"cipherparams": {
			"iv": "da664cd81bcc859b614d76ee87f484a3"
		},
		"ciphertext": "368c855c18d0682a70328fb516f4b0ec51349d5da9e3447fc7658e5d0998eb9a",
		"kdf": "pbkdf2",
		"kdfparams": {
			"c": 262144,
			"dklen": 32,
			"n": 8192,
			"p": 1,
			"r": 8,
			"salt": "af6a500237d826dde0d7973e112b86debb34d82961d18af6e530cb437abaee5f"
		},
		"mac": "7ce219e19a48d21a55cc74b40bda2b110b251ea4a276e9114534b81b9fba8509"
	},
	"id": "34336338-3237-4336-a563-623134303337",
	"version": 3
}
"""

private let keystoreWalletJson = keystoreWalletJSONString.data(using: .utf8)!
