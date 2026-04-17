//
// MIT License
//
// Copyright (c) 2018-2026 Open Zesame (https://github.com/OpenZesame)
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

/// Some uninteresting Zilliqa TESTNET private key, containing worthless TEST tokens.
private let privateKeyString = "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638"

struct AddressValidationTests {
    /// All four formats represent the same address
    @Test(arguments: [
        "zil1uvys5ycfm7kyqdfdq00vdnxeetfp8emtsptv94",
        "ZIL1UVYS5YCFM7KYQDFDQ00VDNXEETFP8EMTSPTV94",
        "e3090a1309DfAC40352d03dEc6cCD9cAd213e76B",
        "0xe3090a1309DfAC40352d03dEc6cCD9cAd213e76B",
    ])
    func equivalentAddressRepresentations(_ addressString: String) throws {
        let canonical = try Address(string: "e3090a1309DfAC40352d03dEc6cCD9cAd213e76B")
        let address = try Address(string: addressString)
        #expect(address == canonical)
    }

    @Test func notChecksummedAddressThrows() {
        #expect(throws: Address.Error.notChecksummed) {
            try Address(string: "E3090a1309DfAC40352d03dEc6cCD9cAd213e76B")
        }
        #expect(throws: Address.Error.notChecksummed) {
            try Address(string: "0xE3090a1309DfAC40352d03dEc6cCD9cAd213e76B")
        }
    }

    @Test func mixedCaseBech32LowercaseLastChar_v_() {
        #expect(
            throws: Address.Error.invalidBech32Address(bechError: Bech32.DecodingError.invalidCase)
        ) {
            try Address(string: "ZIL1UVYS5YCFM7KYQDFDQ00VDNXEETFP8EMTSPTv94")
        }
    }

    @Test func mixedCaseBech32LowercasePrefix() {
        #expect(
            throws: Address.Error.invalidBech32Address(bechError: Bech32.DecodingError.invalidCase)
        ) {
            try Address(string: "zil1UVYS5YCFM7KYQDFDQ00VDNXEETFP8EMTSPTV94")
        }
    }

    @Test(arguments: [
        "zil1uvys5ycfm7kyqdfdq00vdnxeetfp8emtsptv94",
        "0xe3090a1309DfAC40352d03dEc6cCD9cAd213e76B",
        "e3090a1309DfAC40352d03dEc6cCD9cAd213e76B",
    ])
    func allRepresentSameChecksummedAddress(_ addressString: String) throws {
        let address = try Address(string: addressString)
        #expect(try address.toChecksummedLegacyAddress().asString == "e3090a1309DfAC40352d03dEc6cCD9cAd213e76B")
    }

    @Test func addressFromPrivateKeyIsChecksummed() throws {
        let privateKey = try PrivateKey(rawRepresentation: Data(hex: privateKeyString))
        let address = LegacyAddress(privateKey: privateKey)
        #expect(address.asString == "74c544a11795905C2c9808F9e78d8156159d32e4")
        #expect(
            try Address(string: "zil1wnz5fgghjkg9ctycpru70rvp2c2e6vhyc96rwg")
                == Address(string: "74c544a11795905C2c9808F9e78d8156159d32e4")
        )
    }

    @Test func legacyToBech32Address() throws {
        let bech32 = try Bech32Address(
            ethStyleAddress: "74c544a11795905C2c9808F9e78d8156159d32e4",
            network: .mainnet
        )
        #expect(bech32.asString == "zil1wnz5fgghjkg9ctycpru70rvp2c2e6vhyc96rwg")
        #expect(try bech32.toChecksummedLegacyAddress().asString == "74c544a11795905C2c9808F9e78d8156159d32e4")
    }

    @Test func bech32FromTooShortDataThrows() {
        #expect(
            throws: Bech32Address.Error.incorrectDataLength(expectedByteCountOf: 20, butGot: 19)
        ) {
            try Bech32Address(network: .mainnet, unchecksummedData: Data(repeating: 0x1, count: 19))
        }
    }

    @Test(arguments: addressVectors)
    func bech32ToEthStyle(_ vector: AddressVector) throws {
        let addressBech32 = try Address(string: vector.bech32)
        let sameEthStyle = try Address(string: vector.ethStyle)
        #expect(addressBech32 == sameEthStyle)
        let bech32Add = try Bech32Address(bech32String: vector.bech32)
        #expect(bech32Add.asString == vector.bech32)
        #expect(try bech32Add.toChecksummedLegacyAddress().asString == vector.ethStyle)
    }
}

struct AddressVector {
    let ethStyle: String
    let bech32: String
}

private let addressVectors: [AddressVector] = [
    AddressVector(
        ethStyle: "1d19918A737306218b5CBB3241FcdcBd998c3a72",
        bech32: "zil1r5verznnwvrzrz6uhveyrlxuhkvccwnju4aehf"
    ),
    AddressVector(
        ethStyle: "cC8Ee24773e1b4B28B3CC5596bb9Cfc430b48453",
        bech32: "zil1ej8wy3mnux6t9zeuc4vkhww0csctfpznzt4s76"
    ),
    AddressVector(
        ethStyle: "e14576944443E9aeca6f12b454941884aa122938",
        bech32: "zil1u9zhd9zyg056ajn0z269f9qcsj4py2fc89ru3d"
    ),
    AddressVector(
        ethStyle: "179361114cbFD53bE4D3451eDF8148CDE4cfe774",
        bech32: "zil1z7fkzy2vhl2nhexng50dlq2gehjvlem5w7kx8z"
    ),
    AddressVector(
        ethStyle: "5a2B667FdEB6356597681D08F6cD6636AEd94784",
        bech32: "zil1tg4kvl77kc6kt9mgr5y0dntxx6hdj3uy95ash8"
    ),
    AddressVector(
        ethStyle: "537342E5e0a6b402f281E2b4301b89123AE31117",
        bech32: "zil12de59e0q566q9u5pu26rqxufzgawxyghq0vdk9"
    ),
    AddressVector(
        ethStyle: "5e61D42a952D2dF1f4e5cbed7F7D1294e9744A52",
        bech32: "zil1tesag25495klra89e0kh7lgjjn5hgjjj0qmu8l"
    ),
    AddressVector(
        ethStyle: "5F5Db1C18CcDE67e513B7f7Ae820E569154976Ba",
        bech32: "zil1tawmrsvvehn8u5fm0aawsg89dy25ja46ndsrhq"
    ),
]
