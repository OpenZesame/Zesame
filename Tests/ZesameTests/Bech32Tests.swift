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

import Testing
@testable import Zesame

@Suite struct Bech32Tests {
    @Test(arguments: zilliqaVectors)
    func zilliqaVector(_ vector: ZilliqaVector) throws {
        let expectedFullAddress = [vector.prefix, "1", vector.address, vector.checksum].joined()
        let bech32Address = try Bech32Address(bech32String: expectedFullAddress)
        #expect(bech32Address.humanReadablePrefix == vector.prefix)
        #expect(bech32Address.dataPart.checksum.asString == vector.checksum)
        #expect(bech32Address.asString == expectedFullAddress)
    }

    @Test(arguments: validChecksumVectors)
    func validChecksum(_ bech32: String) throws {
        _ = try Bech32.decode(bech32)
    }

    @Test(arguments: invalidChecksumVectors)
    func invalidChecksum(_ vector: InvalidChecksumVector) {
        #expect(throws: vector.error) {
            try Bech32.decode(vector.bech32)
        }
    }
}

struct ZilliqaVector: Sendable {
    let prefix: String
    let address: String
    let checksum: String
}

struct InvalidChecksumVector: Sendable {
    let bech32: String
    let error: Bech32.DecodingError
}

/// https://github.com/Zilliqa/Zilliqa/wiki/Address-Standard#specification
private let zilliqaVectors: [ZilliqaVector] = [
    ZilliqaVector(prefix: "zil", address: "02n74869xnvdwq3yh8p0k9jjgtejruft", checksum: "268tg8"),
    ZilliqaVector(prefix: "zil", address: "48fy8yjxn6jf5w36kqc7x73qd3ufuu24", checksum: "a4u8t9"),
    ZilliqaVector(prefix: "zil", address: "fdv7u7rll9epgcqv9xxh9lhwq427nsql", checksum: "58qcs9"),
]

private let validChecksumVectors: [String] = [
    "A12UEL5L",
    "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
    "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
    "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
    "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
    "?1ezyfcl",
]

private let invalidChecksumVectors: [InvalidChecksumVector] = [
    InvalidChecksumVector(bech32: " 1nwldj5", error: .nonPrintableCharacter),
    InvalidChecksumVector(bech32: "\u{7f}1axkwrx", error: .nonPrintableCharacter),
    InvalidChecksumVector(
        bech32: "an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx",
        error: .stringLengthExceeded
    ),
    InvalidChecksumVector(bech32: "pzry9x0s0muk", error: .noChecksumMarker),
    InvalidChecksumVector(bech32: "1pzry9x0s0muk", error: .incorrectHumanReadablePartSize),
    InvalidChecksumVector(bech32: "x1b4n0q5v", error: .invalidCharacter),
    InvalidChecksumVector(bech32: "li1dgmt3", error: .incorrectChecksumSize),
    InvalidChecksumVector(bech32: "de1lg7wt\u{ff}", error: .nonPrintableCharacter),
    InvalidChecksumVector(bech32: "10a06t8", error: .incorrectHumanReadablePartSize),
    InvalidChecksumVector(bech32: "1qzzfhee", error: .incorrectHumanReadablePartSize),
]
