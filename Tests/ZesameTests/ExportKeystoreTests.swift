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

@Suite struct ExportKeystoreTests {
    @Test func walletImport() async throws {
        let service = DefaultZilliqaService(endpoint: .testnet)
        let keyRestoration = KeyRestoration.privateKey(knownPrivateKey, encryptBy: password, kdf: .pbkdf2)
        let importedWallet = try await service.restoreWallet(from: keyRestoration)
        #expect(importedWallet.keystore.address.asString == expectedAddress)
        #expect(importedWallet.keystore.version == 4)
    }

    @Test func keystoreEncodeDecode() throws {
        let keystore = try Keystore.from(
            privateKey: knownPrivateKey,
            encryptBy: password,
            kdf: .pbkdf2,
            kdfParams: .quickTestParameters
        )
        #expect(keystore.address.asString == expectedAddress)

        let jsonData = try JSONEncoder().encode(keystore)
        let decoded = try JSONDecoder().decode(Keystore.self, from: jsonData)
        #expect(decoded.address.asString == expectedAddress)
        #expect(decoded.version == 4)

        let key = try decoded.decryptPrivateKey(encryptedBy: password)
        #expect(key.rawRepresentation.asHex.uppercased() == expectedPrivateKey.uppercased())
    }
}

private let password = "apabanan"
private let expectedPrivateKey = "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"
private let expectedAddress = "74c544a11795905C2c9808F9e78d8156159d32e4"
private let knownPrivateKey = try! PrivateKey(rawRepresentation: Data(hex: expectedPrivateKey))
