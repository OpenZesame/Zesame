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

import XCTest
@testable import Zesame

final class AddressChecksumTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testEmptyStringFails() {
        XCTAssertNil(try? Address(hexString: ""))
    }

    func test10Vectors() {
        vectors.forEach {
            performTestChecksum(vector: $0)
        }
    }

    func testSomeAddresses() {
        XCTAssertTrue(AddressChecksummed.isChecksummed(hexString: "F510333720c5Dd3c3C08bC8e085e8c981ce74691"))
        XCTAssertTrue(AddressChecksummed.isChecksummed(hexString: "74c544a11795905C2c9808F9e78d8156159d32e4"))
        XCTAssertTrue(AddressChecksummed.isChecksummed(hexString: "9Ca91EB535Fb92Fda5094110FDaEB752eDb9B039"))
    }
}

extension AddressChecksumTests {
    private func performTestChecksum(vector: Vector) {

        func isValid(_ hexString: HexStringConvertible) -> Bool {
            return AddressChecksummed.isChecksummed(hexString: hexString)
        }

        XCTAssertFalse(isValid(vector.ethereumChecksummed))
        XCTAssertFalse(isValid(vector.ethereumChecksummedWithoutLeading0x))
        XCTAssertTrue(isValid(vector.zilliqaChecksummed))
        XCTAssertTrue(isValid(vector.zilliqaChecksummedWithoutLeading0x))

        XCTAssertTrue(AddressChecksummed.checksummedHexstringFrom(hexString: vector.notChecksummed) == vector.zilliqaChecksummedWithoutLeading0x)
    }
}


/// Vectors from Zilliqa JS Library
/// https://github.com/Zilliqa/Zilliqa-JavaScript-Library/blob/9368fb34a0d443797adc1ecbcb9728db9ce75e97/packages/zilliqa-js-crypto/test/checksum.fixtures.ts
typealias Vector = (
    notChecksummed: HexStringConvertible,
    zilliqaChecksummed: HexStringConvertible,
    zilliqaChecksummedWithoutLeading0x: HexStringConvertible,
    ethereumChecksummed: HexStringConvertible,
    ethereumChecksummedWithoutLeading0x: HexStringConvertible
)

extension String: HexStringConvertible {
    public var hexString: HexString {
        do {
            return try HexString(self)
        } catch {
            XCTFail("String: `\(self)` is not valid HexString, error: \(error)")
            return "not a hex string"
        }
    }
}


let vectors: [Vector] = [
    (
        notChecksummed: "4BAF5FADA8E5DB92C3D3242618C5B47133AE003C",
        zilliqaChecksummed: "0x4BAF5faDA8e5Db92C3d3242618c5B47133AE003C",
        zilliqaChecksummedWithoutLeading0x: "4BAF5faDA8e5Db92C3d3242618c5B47133AE003C",
        ethereumChecksummed: "0x4BaF5fADa8E5Db92c3D3242618c5b47133Ae003c",
        ethereumChecksummedWithoutLeading0x: "4BaF5fADa8E5Db92c3D3242618c5b47133Ae003c"
    ),
    (
        notChecksummed: "448261915A80CDE9BDE7C7A791685200D3A0BF4E",
        zilliqaChecksummed: "0x448261915a80cdE9BDE7C7a791685200D3A0bf4E",
        zilliqaChecksummedWithoutLeading0x: "448261915a80cdE9BDE7C7a791685200D3A0bf4E",
        ethereumChecksummedWithoutLeading0x: "448261915a80CDe9bde7C7A791685200d3A0BF4e",
        ethereumChecksummed: "0x448261915a80CDe9bde7C7A791685200d3A0BF4e"
    ),
    (
        notChecksummed: "DED02FD979FC2E55C0243BD2F52DF022C40ADA1E",
        zilliqaChecksummed: "0xDed02fD979fC2e55c0243bd2F52df022c40ADa1E",
        zilliqaChecksummedWithoutLeading0x: "Ded02fD979fC2e55c0243bd2F52df022c40ADa1E",
        ethereumChecksummedWithoutLeading0x: "DED02FD979fC2e55c0243Bd2f52DF022C40aDa1E",
        ethereumChecksummed: "0xDED02FD979fC2e55c0243Bd2f52DF022C40aDa1E"
    ),
    (
        notChecksummed: "13F06E60297BEA6A3C402F6F64C416A6B31E586E",
        zilliqaChecksummed: "0x13F06E60297bea6A3c402F6f64c416A6b31e586e",
        zilliqaChecksummedWithoutLeading0x: "13F06E60297bea6A3c402F6f64c416A6b31e586e",
        ethereumChecksummedWithoutLeading0x: "13f06E60297bEA6A3C402F6F64c416a6B31e586e",
        ethereumChecksummed: "0x13f06E60297bEA6A3C402F6F64c416a6B31e586e"
    ),
    (
        notChecksummed: "1A90C25307C3CC71958A83FA213A2362D859CF33",
        zilliqaChecksummed: "0x1a90C25307C3Cc71958A83fa213A2362D859CF33",
        zilliqaChecksummedWithoutLeading0x: "1a90C25307C3Cc71958A83fa213A2362D859CF33",
        ethereumChecksummedWithoutLeading0x: "1a90c25307c3Cc71958A83fa213a2362D859cF33",
        ethereumChecksummed: "0x1a90c25307c3Cc71958A83fa213a2362D859cF33"
    ),
    (
        notChecksummed: "625ABAEBD87DAE9AB128F3B3AE99688813D9C5DF",
        zilliqaChecksummed: "0x625ABAebd87daE9ab128f3B3AE99688813d9C5dF",
        zilliqaChecksummedWithoutLeading0x: "625ABAebd87daE9ab128f3B3AE99688813d9C5dF",
        ethereumChecksummedWithoutLeading0x: "625aBAEBd87Dae9AB128F3b3ae99688813d9C5Df",
        ethereumChecksummed: "0x625aBAEBd87Dae9AB128F3b3ae99688813d9C5Df"
    ),
    (
        notChecksummed: "36BA34097F861191C48C839C9B1A8B5912F583CF",
        zilliqaChecksummed: "0x36Ba34097f861191C48C839c9b1a8B5912f583cF",
        zilliqaChecksummedWithoutLeading0x: "36Ba34097f861191C48C839c9b1a8B5912f583cF",
        ethereumChecksummedWithoutLeading0x: "36BA34097f861191c48c839c9B1A8B5912f583cf",
        ethereumChecksummed: "0x36BA34097f861191c48c839c9B1A8B5912f583cf"
    ),
    (
        notChecksummed: "D2453AE76C9A86AAE544FCA699DBDC5C576AEF3A",
        zilliqaChecksummed: "0xD2453Ae76C9A86AAe544fca699DbDC5c576aEf3A",
        zilliqaChecksummedWithoutLeading0x: "D2453Ae76C9A86AAe544fca699DbDC5c576aEf3A",
        ethereumChecksummedWithoutLeading0x: "D2453AE76c9a86AAE544FCa699DBdC5C576aEf3A",
        ethereumChecksummed: "0xD2453AE76c9a86AAE544FCa699DBdC5C576aEf3A"
    ),
    (
        notChecksummed: "72220E84947C36118CDBC580454DFAA3B918CD97",
        zilliqaChecksummed: "0x72220e84947c36118cDbC580454DFaa3b918cD97",
        zilliqaChecksummedWithoutLeading0x: "72220e84947c36118cDbC580454DFaa3b918cD97",
        ethereumChecksummedWithoutLeading0x: "72220E84947c36118CDbc580454DfaA3B918cd97",
        ethereumChecksummed: "0x72220E84947c36118CDbc580454DfaA3B918cd97"
    ),
    (
        notChecksummed: "50F92304C892D94A385CA6CE6CD6950CE9A36839",
        zilliqaChecksummed: "0x50f92304c892D94A385cA6cE6CD6950ce9A36839",
        zilliqaChecksummedWithoutLeading0x: "50f92304c892D94A385cA6cE6CD6950ce9A36839",
        ethereumChecksummedWithoutLeading0x: "50f92304c892d94A385Ca6ce6cD6950ce9A36839",
        ethereumChecksummed: "0x50f92304c892d94A385Ca6ce6cD6950ce9A36839"
    )
]

