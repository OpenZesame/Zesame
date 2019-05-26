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

/// Found: https://github.com/0xDEADP00L/Bech32/blob/master/Sources/Bech32.swift

/// Bech32 checksum implementation
public enum Bech32 {}

public struct DataAndString {
    public let asData: Data
    public let asString: String
}

public extension Bech32 {
    struct Decoded {
        
        public struct DataPart {
            public let excludingChecksum: DataAndString?
            public let checksum: DataAndString
            public var includingChecksum: DataAndString {
                guard let excludingChecksum = excludingChecksum else {
                    return checksum
                }
                return DataAndString(
                    asData: excludingChecksum.asData + checksum.asData,
                    asString: excludingChecksum.asString + checksum.asString
                )
            }
        }
        
        public let humanReadablePrefix: String
        public let dataPart: DataPart
        
    }
}

public extension Bech32 {
    
    static func validate(_ string: String) throws {
        _  = try decode(string)
    }
    
    /// Encode Bech32 string
    static func encode(_ humanReadablePart: String, values: Data) -> String {
        let checksum = createChecksum(humanReadablePart: humanReadablePart, values: values)
        var combined = values
        combined.append(checksum)

        return [
            humanReadablePart,
            checksumMarker,
            dataToString(data: combined)
        ].joined()
        
    }
    
    static func dataToString(data: Data) -> String {
        var ret = "".data(using: .utf8)!
        for i in data {
            ret.append(charsetForEncoding[Int(i)])
        }
        return String(data: ret, encoding: .utf8) ?? ""
    }
    
    /// Decode Bech32 string
    static func decode(_ str: String) throws -> Decoded {
        guard let strBytes = str.data(using: .utf8) else {
            throw DecodingError.nonUTF8String
        }
        guard strBytes.count <= 90 else {
            throw DecodingError.stringLengthExceeded
        }
        var lower: Bool = false
        var upper: Bool = false
        for c in strBytes {
            // printable range
            if c < 33 || c > 126 {
                throw DecodingError.nonPrintableCharacter
            }
            // 'a' to 'z'
            if c >= 97 && c <= 122 {
                lower = true
            }
            // 'A' to 'Z'
            if c >= 65 && c <= 90 {
                upper = true
            }
        }
        if lower && upper {
            throw DecodingError.invalidCase
        }
        guard let pos = str.range(of: checksumMarker, options: .backwards)?.lowerBound else {
            throw DecodingError.noChecksumMarker
        }
        let intPos: Int = str.distance(from: str.startIndex, to: pos)
        guard intPos >= 1 else {
            throw DecodingError.incorrectHumanReadablePartSize
        }
        guard intPos + 7 <= str.count else {
            throw DecodingError.incorrectChecksumSize
        }
        let vSize: Int = str.count - 1 - intPos
        var values: Data = Data(repeating: 0x00, count: vSize)
        for i in 0..<vSize {
            let c = strBytes[i + intPos + 1]
            let decInt = charsetForDecoding[Int(c)]
            if decInt == -1 {
                throw DecodingError.invalidCharacter
            }
            values[i] = UInt8(decInt)
        }
        let humanReadablePart = String(str[..<pos]).lowercased()
        guard verifyChecksum(humanReadablePart: humanReadablePart, checksum: values) else {
            throw DecodingError.checksumMismatch
        }
        
        let humanReadablePrefix = humanReadablePart
        let checksumLength = 6
        let humanReadableRelevantData = values.prefix(upTo: values.count - checksumLength)
        let humanReadableRelevantString = dataToString(data: humanReadableRelevantData)
        let checksumData = values.suffix(checksumLength)
        let checksumString = dataToString(data: checksumData)
        
        let excludingChecksumDataAndString: DataAndString? = {
            guard !humanReadableRelevantString.isEmpty else {
                return nil
            }
            return DataAndString(asData: humanReadableRelevantData, asString: humanReadableRelevantString)
        }()
        
        let dataPart = Decoded.DataPart(
            excludingChecksum: excludingChecksumDataAndString,
            checksum: DataAndString(asData: checksumData, asString: checksumString)
        )
        
        return Decoded(
            humanReadablePrefix: humanReadablePrefix,
            dataPart: dataPart
        )
    }
}

private extension Bech32 {
    static let generator: [UInt32] = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
    
    /// Bech32 checksum delimiter
    static let checksumMarker: String = "1"
    
    /// Bech32 character set for encoding
    static let charsetForEncoding: Data = "qpzry9x8gf2tvdw0s3jn54khce6mua7l".data(using: .utf8)!
    
    /// Bech32 character set for decoding
    static let charsetForDecoding: [Int8] = [
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        15, -1, 10, 17, 21, 20, 26, 30,  7,  5, -1, -1, -1, -1, -1, -1,
        -1, 29, -1, 24, 13, 25,  9,  8, 23, -1, 18, 22, 31, 27, 19, -1,
        1,  0,  3, 16, 11, 28, 12, 14,  6,  4,  2, -1, -1, -1, -1, -1,
        -1, 29, -1, 24, 13, 25,  9,  8, 23, -1, 18, 22, 31, 27, 19, -1,
        1,  0,  3, 16, 11, 28, 12, 14,  6,  4,  2, -1, -1, -1, -1, -1
    ]
}

private extension Bech32 {
    
    /// Find the polynomial with value coefficients mod the generator as 30-bit.
    static func polymod(_ values: Data) -> UInt32 {
        var chk: UInt32 = 1
        for v in values {
            let top = (chk >> 25)
            chk = (chk & 0x1ffffff) << 5 ^ UInt32(v)
            for i: UInt8 in 0..<5 {
                chk ^= ((top >> i) & 1) == 0 ? 0 : generator[Int(i)]
            }
        }
        return chk
    }
    
    /// Expand a HRP for use in checksum computation.
    static func expandHumanReadablePart(_ humanReadablePart: String) -> Data {
        guard let humanReadablePartBytes = humanReadablePart.data(using: .utf8) else { return Data() }
        var result = Data(repeating: 0x00, count: humanReadablePartBytes.count*2+1)
        for (i, c) in humanReadablePartBytes.enumerated() {
            result[i] = c >> 5
            result[i + humanReadablePartBytes.count + 1] = c & 0x1f
        }
        result[humanReadablePart.count] = 0
        return result
    }
    
    /// Verify checksum
    static func verifyChecksum(humanReadablePart: String, checksum: Data) -> Bool {
        var data = expandHumanReadablePart(humanReadablePart)
        data.append(checksum)
        return polymod(data) == 1
    }
    
    /// Create checksum
    static func createChecksum(humanReadablePart: String, values: Data) -> Data {
        var enc = expandHumanReadablePart(humanReadablePart)
        enc.append(values)
        enc.append(Data(repeating: 0x00, count: 6))
        let mod: UInt32 = polymod(enc) ^ 1
        var ret: Data = Data(repeating: 0x00, count: 6)
        for i in 0..<6 {
            ret[i] = UInt8((mod >> (5 * (5 - i))) & 31)
        }
        return ret
    }
}


public extension Bech32 {
    enum DecodingError: LocalizedError {
        case nonUTF8String
        case nonPrintableCharacter
        case invalidCase
        case noChecksumMarker
        case incorrectHumanReadablePartSize
        case incorrectChecksumSize
        case stringLengthExceeded
        
        case invalidCharacter
        case checksumMismatch
        
        public var errorDescription: String? {
            switch self {
            case .checksumMismatch:
                return "Checksum doesn't match"
            case .incorrectChecksumSize:
                return "Checksum size too low"
            case .incorrectHumanReadablePartSize:
                return "Human-readable-part is too small or empty"
            case .invalidCase:
                return "String contains mixed case characters"
            case .invalidCharacter:
                return "Invalid character met on decoding"
            case .noChecksumMarker:
                return "Checksum delimiter not found"
            case .nonPrintableCharacter:
                return "Non printable character in input string"
            case .nonUTF8String:
                return "String cannot be decoded by utf8 decoder"
            case .stringLengthExceeded:
                return "Input string is too long"
            }
        }
    }
}
