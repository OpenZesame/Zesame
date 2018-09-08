//
//  KeyGenerationTests.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-06-30.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

import XCTest
@testable import ZilliqaSDK_iOS

class KeyGenerationTests: XCTestCase {

    func testKeyPair() {
        let privateKey: PrivateKey = "0x29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618e"

        let expected_public_key_uncompressed = "04f979f942ae743f27902b62ca4e8a8fe0f8a979ee3ad7bd0817339a665c3e7f4fb8cf959134b5c66bcc333a968b26d0adaccfad26f1ea8607d647e5b679c49184"

        XCTAssertEqual(expected_public_key_uncompressed.count, 130, "Uncompressed public keys should be 130 chars long")

        let expected_public_key_compressed = "02f979f942ae743f27902b62ca4e8a8fe0f8a979ee3ad7bd0817339a665c3e7f4f"

        XCTAssertEqual(expected_public_key_compressed.count, 66, "Uncompressed public keys should be 130 chars long")

        let publicKeyUncompressed = PublicKey(privateKey: privateKey, format: .uncompressed)
        let publicKeyUncompressedHex = publicKeyUncompressed.toHexString()
        XCTAssertEqual(publicKeyUncompressedHex, expected_public_key_uncompressed)
        let publicKeyCompressed = PublicKey(privateKey: privateKey, format: .compressed)
        let publicKeyCompressedHex = publicKeyCompressed.toHexString()
        XCTAssertEqual(publicKeyCompressedHex, expected_public_key_compressed)

    }
}
