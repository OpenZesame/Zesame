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
        XCTAssertTrue(try Address(string: "zil1uvys5ycfm7kyqdfdq00vdnxeetfp8emtsptv94").isChecksummed)
        XCTAssertTrue(try Address(string: "ZIL1UVYS5YCFM7KYQDFDQ00VDNXEETFP8EMTSPTV94").isChecksummed)
        XCTAssertTrue(try Address(string: "F510333720c5Dd3c3C08bC8e085e8c981ce74691").isChecksummed)
        XCTAssertTrue(try Address(string: "0xF510333720c5Dd3c3C08bC8e085e8c981ce74691").isChecksummed)
        XCTAssertThrowsSpecificError(
            try Address(string: "f510333720c5Dd3c3C08bC8e085e8c981ce74691"),
            Address.Error.notChecksummed
        )
        XCTAssertThrowsSpecificError(
            try Address(string: "0xf510333720c5Dd3c3C08bC8e085e8c981ce74691"),
            Address.Error.notChecksummed
        )
    }
    
    func testMixedCaseBech32LowercaseLastChar_v_() {
        XCTAssertThrowsSpecificError(
            try Address(string: "ZIL1UVYS5YCFM7KYQDFDQ00VDNXEETFP8EMTSPTv94"),
            Address.Error.invalidBech32Address(bechError: Bech32.DecodingError.invalidCase),
            "lower case last chars `v`, uppercase rest"
        )
    }
    
    func testMixedCaseBech32LowercasePrefix() {
        XCTAssertThrowsSpecificError(
            try Address(string: "zil1UVYS5YCFM7KYQDFDQ00VDNXEETFP8EMTSPTV94"),
            Address.Error.invalidBech32Address(bechError: Bech32.DecodingError.invalidCase),
            "lower case prefix, uppercase rest"
        )

    }
    
    func testSame() {
        do {
            try XCTAssertAllEqual(items:
                [
                    [
                        "zil1uvys5ycfm7kyqdfdq00vdnxeetfp8emtsptv94",
                        "0xe3090a1309DfAC40352d03dEc6cCD9cAd213e76B",
                        "e3090a1309DfAC40352d03dEc6cCD9cAd213e76B"
                    ].map { try Address(string: $0).asString },
                    ["e3090a1309DfAC40352d03dEc6cCD9cAd213e76B"]
                ].flatMap { $0 }
            )
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testThatAddressFromPrivateKeyIsChecksummed() {
        let privateKey = PrivateKey(hex: privateKeyString)!
        let address = Address(privateKey: privateKey)
        XCTAssertTrue(address.isChecksummed)
        XCTAssertEqual(address, "74c544a11795905C2c9808F9e78d8156159d32e4")
        
        XCTAssertEqual(
            try Address(string: "zil1wnz5fgghjkg9ctycpru70rvp2c2e6vhyc96rwg").asString,
            try Address(string: "74c544a11795905C2c9808F9e78d8156159d32e4").asString
        )
        
    }
    
    func testBech32ToEthStyle() {
        func doTest(_ vector: AddressTuple) {
            do {
                let addressBech32 = try Address(string: vector.bech32)
                let sameEthStyle = try Address(string: vector.ethStyle)
                XCTAssertEqual(addressBech32, sameEthStyle)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        vectors.forEach {
            doTest($0)
        }
    }

}

private typealias AddressTuple = (ethStyle: String, bech32: String)

private let vectors: [AddressTuple] = [
    (
        ethStyle: "1d19918A737306218b5CBB3241FcdcBd998c3a72",
        bech32: "zil1r5verznnwvrzrz6uhveyrlxuhkvccwnju4aehf"
    ),
    (
        ethStyle: "cC8Ee24773e1b4B28B3CC5596bb9Cfc430b48453",
        bech32: "zil1ej8wy3mnux6t9zeuc4vkhww0csctfpznzt4s76"
    ),
    (
        ethStyle: "e14576944443E9aeca6f12b454941884aa122938",
        bech32: "zil1u9zhd9zyg056ajn0z269f9qcsj4py2fc89ru3d"
    ),
    (
        ethStyle: "179361114cbFD53bE4D3451eDF8148CDE4cfe774",
        bech32: "zil1z7fkzy2vhl2nhexng50dlq2gehjvlem5w7kx8z"
    ),
    (
        ethStyle: "5a2B667FdEB6356597681D08F6cD6636AEd94784",
        bech32: "zil1tg4kvl77kc6kt9mgr5y0dntxx6hdj3uy95ash8"
    ),
    (
        ethStyle: "537342E5e0a6b402f281E2b4301b89123AE31117",
        bech32: "zil12de59e0q566q9u5pu26rqxufzgawxyghq0vdk9"
    ),
    (
        ethStyle: "5e61D42a952D2dF1f4e5cbed7F7D1294e9744A52",
        bech32: "zil1tesag25495klra89e0kh7lgjjn5hgjjj0qmu8l"
    ),
    (
        ethStyle: "5F5Db1C18CcDE67e513B7f7Ae820E569154976Ba",
        bech32: "zil1tawmrsvvehn8u5fm0aawsg89dy25ja46ndsrhq"
    )
]
