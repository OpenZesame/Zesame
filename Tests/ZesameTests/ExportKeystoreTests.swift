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

    func testWalletImport() async throws {
        
        let service = DefaultZilliqaService(endpoint: .testnet)
        let keyRestoration = try KeyRestoration(keyStoreJSONString: keystoreWalletJSONString, encryptedBy: password)
        let importedWallet = try await service.restoreWallet(from: keyRestoration)
        
        XCTAssertEqual(importedWallet.keystore.address.asString, "74c544a11795905C2c9808F9e78d8156159d32e4")
    }
    
    func testKeystoreDecoding() async throws {
        let json = keystoreWalletJSONString.data(using: .utf8)!
        let keystore = try JSONDecoder().decode(Keystore.self, from: json)
        XCTAssertEqual(keystore.address.asString, "74c544a11795905C2c9808F9e78d8156159d32e4")
        
        guard let privateKey = await keystore.decryptPrivateKey(password: password) else {
            XCTFail("Expected to be able to decrypt keystore.")
            return
        }
        XCTAssertEqual(privateKey.asHex(), expectedPrivateKey.uppercased())
    }
}


private let password = "apabanan"
private let expectedPrivateKey = "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"
private let keystoreWalletJSONString = """
{
  "version" : 3,
  "id" : "10535E93-0A9D-428D-9AEF-E7A9D0C8B68B",
  "crypto" : {
    "ciphertext" : "59aaba249ec0fcf68e072a33fa31d8e8041622889bc4cb39faaf10602729da4a",
    "cipherparams" : {
      "iv" : "9dd4cbb5bf330bcf62db9d32112859e6"
    },
    "kdf" : "pbkdf2",
    "kdfparams" : {
      "r" : 8,
      "p" : 1,
      "n" : 2,
      "c" : 2,
      "dklen" : 32,
      "salt" : "74cdee1367621c21d9217ff7a0db1efe9625a3fd0c486e40bc02f3a5e82c45a8"
    },
    "mac" : "18ae9db76c5f72cabf7003d0946a95581695d9041e4c24e4aa627ed2aef52e39",
    "cipher" : "aes-128-ctr"
  },
  "address" : "74c544a11795905C2c9808F9e78d8156159d32e4"
}
"""

