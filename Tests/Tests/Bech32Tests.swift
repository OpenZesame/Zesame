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

class Bech32Tests: XCTestCase {
    
    func test3Vectors() {
        func doTest(_ vector: ZilliqaVector) {
            do {
                let expectedFullAddress = [vector.prefix, "1", vector.address, vector.checksum].joined()
//
//                let decoded = try Bech32.decode(bech32Address)
//
//               print("\nVector: '\(bech32Address)' =>\nPrefix: '\(decoded.humanReadablePrefix)',\nPayload: '\(decoded.dataPart.excludingChecksum?.asString)',\nChecksum: '\(decoded.dataPart.checksum.asString)'\n")
                let bech32Address = try Bech32Address(bech32String: expectedFullAddress)
                
                XCTAssertEqual(bech32Address.humanReadablePrefix, vector.prefix)
                XCTAssertEqual(bech32Address.dataPart.checksum.asString, vector.checksum)
                XCTAssertEqual(bech32Address.asString(), expectedFullAddress)
            } catch {
                XCTFail("Error: \(error)")
            }
        }
        zilliqaVectors.forEach {
            doTest($0)
        }
    }
    
    
    func testFo() throws {
        try validChecksumVectors.forEach {
            let decoded = try Bech32.decode($0)
//            let encoded = try Bech32.encode(decoded.humanReadablePart, values: decoded.checksum)
//            let dataChecksum = String(data: decoded.checksum, encoding: .utf8)!
            print("\nVector: '\($0)' =>\nPrefix: '\(decoded.humanReadablePrefix)',\nPayload: '\(decoded.dataPart.excludingChecksum?.asString)',\nChecksum: '\(decoded.dataPart.checksum.asString)'\n")
        }
    }
    
    func testValidChecksums() {
        func doTest(_ valid: String) {
            XCTAssertNoThrow(
                try Bech32.decode(valid),
                "Valid checksum should not throw when decoded"
            )
        }
        
        validChecksumVectors.forEach {
            doTest($0)
        }
    }
    
    func testInvalidChecksums() {
        func doTest(_ invalid: InvalidChecksum) {
            XCTAssertThrowsError(
                try Bech32.decode(invalid.bech32),
                "Expect Bech32.DecodingError: \(invalid.error)") { error in
                    guard let bech32Error = error as? Bech32.DecodingError else {
                        return XCTFail("Wrong error type, got error: \(error), expected to be of type \(type(of: Bech32.DecodingError.self))")
                    }
                    XCTAssertEqual(bech32Error, invalid.error)
            }
        }
        
        invalidChecksumVectors.forEach {
            doTest($0)
        }
    }
}

fileprivate typealias ZilliqaVector = (prefix: String, address: String, checksum: String)

/// https://github.com/Zilliqa/Zilliqa/wiki/Address-Standard#specification
private let zilliqaVectors: [ZilliqaVector] = [
    (
        prefix: "zil",
        address: "02n74869xnvdwq3yh8p0k9jjgtejruft",
        checksum: "268tg8"
    ),
    (
        prefix: "zil",
        address: "48fy8yjxn6jf5w36kqc7x73qd3ufuu24",
        checksum: "a4u8t9"
    ),
    (
        prefix: "zil",
        address: "fdv7u7rll9epgcqv9xxh9lhwq427nsql",
        checksum: "58qcs9"
    )
]

private let validChecksumVectors: [String] = [
    "A12UEL5L",
    "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
    "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
    "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
    "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
    "?1ezyfcl"
]

private let invalidChecksumVectors: [InvalidChecksum] = [
    (" 1nwldj5", Bech32.DecodingError.nonPrintableCharacter),
    ("\u{7f}1axkwrx", Bech32.DecodingError.nonPrintableCharacter),
    ("an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx", Bech32.DecodingError.stringLengthExceeded),
    ("pzry9x0s0muk", Bech32.DecodingError.noChecksumMarker),
    ("1pzry9x0s0muk", Bech32.DecodingError.incorrectHumanReadablePartSize),
    ("x1b4n0q5v", Bech32.DecodingError.invalidCharacter),
    ("li1dgmt3", Bech32.DecodingError.incorrectChecksumSize),
    ("de1lg7wt\u{ff}", Bech32.DecodingError.nonPrintableCharacter),
    ("10a06t8", Bech32.DecodingError.incorrectHumanReadablePartSize),
    ("1qzzfhee", Bech32.DecodingError.incorrectHumanReadablePartSize)
]

fileprivate typealias InvalidChecksum = (bech32: String, error: Bech32.DecodingError)
