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
            XCTAssertEqual(Address.checksummed(address.checksummedAddress), try Address(string: "F510333720c5Dd3c3C08bC8e085e8c981ce74691"))
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
