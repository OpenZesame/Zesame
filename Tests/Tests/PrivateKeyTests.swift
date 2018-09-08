//
//  PrivateKeyTests.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-06-30.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import XCTest
@testable import ZilliqaSDK_iOS

class PrivateKeyTests: XCTestCase {
    

    func testPrivateKeyFromString() {
        guard let privateKey = PrivateKey(string: "0x29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618e") else {
            return XCTFail("private key should not be nil")
        }
        guard let lesser = PrivateKey(string: "0x29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618d") else {
            return XCTFail("private key should not be nil")
        }
        guard let greater = PrivateKey(string: "0x29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618f") else {
            return XCTFail("private key should not be nil")
        }
        XCTAssertGreaterThan(privateKey.randomBigNumber, lesser.randomBigNumber)
        XCTAssertGreaterThan(greater.randomBigNumber, privateKey.randomBigNumber)
    }

    func testPrivateKeyHexString() {
        guard let privateKey = PrivateKey(string: "0x29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618e") else {
            return XCTFail("private key should not be nil")
        }

        XCTAssertEqual(privateKey.toHexString(), "0x29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618e")
    }

}
