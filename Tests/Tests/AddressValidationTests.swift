//
//  AddressValidationTests.swift
//  Zesame
//
//  Created by Alexander Cyon on 2019-01-12.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation

import XCTest
@testable import Zesame

// Some uninteresting Zilliqa TESTNET private key, containing worthless TEST tokens.
private let privateKeyString = "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"

final class AddressValidationTests: XCTestCase {

    func testChecksummedAddress() {
        XCTAssertTrue(try Address(string: "F510333720c5Dd3c3C08bC8e085e8c981ce74691").isChecksummed)
    }

    func testNotchecksummedAddress() {
        do {
            // changed leading uppercase "F" to lowercase
            let address = try Address(string: "f510333720c5Dd3c3C08bC8e085e8c981ce74691")
            XCTAssertFalse(address.isChecksummed)
            XCTAssertTrue(AddressChecksummed.isChecksummed(hexString: address.checksummedAddress) )
        } catch {
            return XCTFail("Test should not throw")
        }
    }

    func testAddressEquatable() {
        let lhs: Address = "F510333720c5Dd3c3C08bC8e085e8c981ce74691"
        let rhs: Address = "f510333720c5Dd3c3C08bC8e085e8c981ce74691"
        XCTAssertNotEqual(lhs, rhs)
    }

    func testThatAddressFromPrivateKeyIsChecksummed() {
        let privateKey = PrivateKey(hex: privateKeyString)!
        let address = Address(privateKey: privateKey)
        XCTAssertTrue(address.isChecksummed)
        XCTAssertEqual(address, "74c544a11795905C2c9808F9e78d8156159d32e4")
    }

}
