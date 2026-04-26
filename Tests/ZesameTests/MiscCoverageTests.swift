import BigInt
import Combine
import Foundation
import Testing
@testable import Zesame

struct BigUIntStringInitTests {
    @Test func initFromDecimalString() {
        let n = BigUInt(string: "12345")
        #expect(n == 12345)
    }

    @Test func initFromHexStringWith0xPrefix() {
        let n = BigUInt(string: "0xff")
        #expect(n == 255)
    }

    @Test func initFromHexStringWithUppercase0xPrefix() {
        let n = BigUInt(string: "0xFF")
        #expect(n == 255)
    }

    @Test func initFromInvalidReturnsNil() {
        let n = BigUInt(string: "notanumber")
        #expect(n == nil)
    }

    @Test func initFromEmptyString() {
        let n = BigUInt(string: "")
        #expect(n == nil)
    }

    @Test func splittingIntoSubstrings() {
        let s = "AABBCCDD"
        let parts = s.splittingIntoSubStringsOfLength(2)
        #expect(parts == ["AA", "BB", "CC", "DD"])
    }
}

struct EncodableDictionaryTests {
    struct Simple: Encodable {
        let name: String
        let value: Int
    }

    @Test func asDictionary() throws {
        let obj = Simple(name: "test", value: 42)
        let dict = try obj.asDictionary()
        #expect(dict["name"] as? String == "test")
        #expect(dict["value"] as? Int == 42)
    }
}

struct DataConvertibleTests {
    @Test func hexStringBytesAndAsHex() {
        let hex: HexString = "deadbeef"
        #expect(Array(hex.asData) == [0xDE, 0xAD, 0xBE, 0xEF])
        #expect(hex.asHex == "deadbeef")
    }

    @Test func uInt8ArrayAsData() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03]
        let data = bytes.asData
        #expect(data == Data([0x01, 0x02, 0x03]))
    }
}

struct HexStringTests {
    @Test func initValid() throws {
        let input = "ab" + "cdef"
        let hex = try HexString(input)
        #expect(hex.value == "abcdef")
    }

    @Test func initStripsLeading0x() throws {
        let input = "0x" + "abcdef"
        let hex = try HexString(input)
        #expect(hex.value == "abcdef")
    }

    @Test func initWithUppercase() throws {
        let input = "AB" + "CDEF"
        let hex = try HexString(input)
        #expect(hex.value == "ABCDEF")
    }

    @Test func initInvalidThrows() {
        // Build at runtime so Swift doesn't use init(stringLiteral:) path
        let invalid = "x" + "y" + "z" + "!"
        let result = try? HexString(invalid)
        #expect(result == nil)
    }

    @Test func stringLiteral() {
        let hex: HexString = "cafe"
        #expect(hex.value == "cafe")
    }

    @Test func length() throws {
        let input = "ab" + "cd"
        let hex = try HexString(input)
        #expect(hex.length == 4)
    }

    @Test func description() throws {
        let input = "ab" + "cd"
        let hex = try HexString(input)
        #expect(hex.description == "abcd")
    }

    @Test func decodeFromJSONString() throws {
        // HexString.init(from:) uses a single value container (decodes from plain string)
        let jsonString = "\"abcd\""
        let data = try #require(jsonString.data(using: .utf8))
        let decoded = try JSONDecoder().decode(HexString.self, from: data)
        #expect(decoded.value == "abcd")
    }

    @Test func droppingLeading0x() {
        #expect("0x1234".droppingLeading0x() == "1234")
        #expect("0x0xabcd".droppingLeading0x() == "abcd")
        #expect("plain".droppingLeading0x() == "plain")
    }

    @Test func asData() {
        let hex: HexString = "deadbeef"
        #expect(hex.asData == Data([0xDE, 0xAD, 0xBE, 0xEF]))
    }

    @Test func hashable() {
        let h1: HexString = "abcd"
        let h2: HexString = "abcd"
        var set = Set<HexString>()
        set.insert(h1)
        set.insert(h2)
        #expect(set.count == 1)
    }
}

struct AddressStringLiteralTests {
    @Test func initFromLegacyHexStringLiteral() {
        let address: Address = "1234567890123456789012345678901234567890"
        if case .legacy = address {
            // expected
        } else {
            Issue.record("Expected .legacy address")
        }
    }

    @Test func initFromBech32StringLiteral() {
        let address: Address = "zil1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq9yf6pz"
        if case .bech32 = address {
            // expected
        } else {
            Issue.record("Expected .bech32 address")
        }
    }

    @Test func addressEquality() {
        let a1: Address = "1234567890123456789012345678901234567890"
        let a2: Address = "1234567890123456789012345678901234567890"
        #expect(a1 == a2)
    }

    @Test func addressAsString() {
        let a: Address = "1234567890123456789012345678901234567890"
        #expect(!a.asString.isEmpty)
    }
}

struct LegacyAddressCodableTests {
    @Test func encode() throws {
        let address = try LegacyAddress(string: "1234567890123456789012345678901234567890")
        let data = try JSONEncoder().encode(address)
        let str = try #require(String(data: data, encoding: .utf8))
        #expect(str.contains("1234567890123456789012345678901234567890"))
    }

    @Test func decode() throws {
        let json = "\"1234567890123456789012345678901234567890\""
        let data = try #require(json.data(using: .utf8))
        let address = try JSONDecoder().decode(LegacyAddress.self, from: data)
        #expect(!address.asString.isEmpty)
    }

    @Test func decodeInvalid() throws {
        let json = "\"notanaddress\""
        let data = try #require(json.data(using: .utf8))
        #expect(throws: (any Swift.Error).self) {
            _ = try JSONDecoder().decode(LegacyAddress.self, from: data)
        }
    }
}

struct DoubleZilLiQaTests {
    @Test func intExtensionsZil() {
        let z = 5.zil
        #expect(z.zilString == "5")
    }

    @Test func intExtensionsLi() {
        let l = 1000.li
        #expect(!l.liString.isEmpty)
    }

    @Test func intExtensionsQa() {
        let q = 100.qa
        #expect(q.qaString == "100")
    }

    @Test func magnitudeZil() {
        let mag: Zil.Magnitude = 2
        let z = mag.zil
        #expect(z.zilString == "2")
    }

    @Test func magnitudeLi() {
        let mag: Li.Magnitude = 500
        let l = mag.li
        #expect(!l.liString.isEmpty)
    }

    @Test func magnitudeQa() {
        let mag: Qa.Magnitude = 999
        let q = mag.qa
        #expect(q.qaString == "999")
    }
}

struct HexStringChecksummedTests {
    @Test func checksummed() {
        // HexString.checksummed returns a LegacyAddress with checksumming applied
        let hex: HexString = "4baf5fada8e5db92c3d3242618c5b47133ae003c"
        let checksummed = hex.checksummed
        // The checksummed address should be a valid non-empty address
        #expect(!checksummed.asString.isEmpty)
        #expect(checksummed.asString.count == 40)
    }

    @Test func checksummedPreservesDigits() {
        // A hex string with only digits (no letters to checksum)
        let hex: HexString = "1234567890123456789012345678901234567890"
        let checksummed = hex.checksummed
        // Digits don't change with checksumming
        #expect(checksummed.asString == "1234567890123456789012345678901234567890")
    }
}

struct DoubleAsStringTests {
    @Test func noDecimalSeparatorReturnsAsIs() {
        // String with no decimal separator → returned unchanged
        let result = Double(1.0).asStringWithoutTrailingZeros
        #expect(!result.contains("."))
    }

    @Test func trailingZerosStripped() {
        // Build a Double that when formatted has trailing zeros.
        // 1.5 → "1.5" (no trailing zeros, already minimal)
        let result = Double(1.5).asStringWithoutTrailingZeros
        #expect(result == "1.5")
    }
}

struct UnitConversionTests2 {
    @Test func asZil() throws {
        let amount = try Amount(qa: "1000000000000")
        let zil = amount.asZil
        #expect(zil.zilString == "1")
    }

    @Test func asLi() throws {
        let amount = try Amount(qa: "1000000")
        let li = amount.asLi
        #expect(!li.liString.isEmpty)
    }

    @Test func asQa() throws {
        let amount = try Amount(qa: "500")
        let qa = amount.asQa
        #expect(qa.qaString == "500")
    }
}

struct UnitPowerOfTests {
    @Test func unitPowerOfStrings() {
        #expect(Unit.zil.powerOf == "10^0")
        #expect(Unit.li.powerOf == "10^-6")
        #expect(Unit.qa.powerOf == "10^-12")
    }

    @Test func expressibleByAmountStaticPowerOf() {
        #expect(Zil.powerOf == "10^0")
        #expect(Li.powerOf == "10^-6")
        #expect(Qa.powerOf == "10^-12")
    }
}

struct KDFParamsDefaultUniquenessTests {
    /// Regression: ``KDFParams.default`` was a `static let`, so every keystore created without
    /// explicit kdfParams reused one process-wide salt. It's now a computed property — each
    /// access must produce a freshly-generated salt.
    @Test func defaultProducesFreshSaltPerAccess() {
        let a = KDFParams.default
        let b = KDFParams.default
        #expect(a.saltHex != b.saltHex)
    }

    @Test func kdfDefaultParametersForwardsToFreshDefault() {
        let a = KDF.defaultParameters
        let b = KDF.defaultParameters
        #expect(a.saltHex != b.saltHex)
    }
}

struct KeystoreToJsonTests {
    @Test func toJsonContainsVersion() throws {
        let keystore = try Keystore.makeTest()
        let json = try keystore.toJson()
        #expect(json["version"] as? Int == 4)
    }
}

struct KeystorePasswordShortTests {
    private let privKey = try! PrivateKey(
        rawRepresentation: Data(hex: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638")
    )

    @Test func fromPrivateKeyWithShortPasswordThrows() {
        #expect(throws: (any Swift.Error).self) {
            try Keystore.from(privateKey: privKey, encryptBy: "short", kdf: .pbkdf2)
        }
    }

    @Test func decryptWithShortPasswordThrows() throws {
        let keystore = try Keystore.makeTest()
        #expect(throws: (any Swift.Error).self) {
            try keystore.decryptPrivateKey(encryptedBy: "short")
        }
    }
}

struct LegacyAddressKeyPairInitTests {
    @Test func initFromKeyPair() throws {
        let privKey = try PrivateKey(
            rawRepresentation: Data(hex: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638")
        )
        let address = LegacyAddress(keyPair: KeyPair(private: privKey))
        #expect(address.asString.count == 40)
    }
}

struct Bech32DecodingErrorDescriptionTests {
    @Test func allCasesHaveErrorDescription() {
        let errors: [Bech32.DecodingError] = [
            .checksumMismatch, .incorrectChecksumSize, .incorrectHumanReadablePartSize,
            .invalidCase, .invalidCharacter, .noChecksumMarker,
            .nonPrintableCharacter, .nonUTF8String, .stringLengthExceeded,
        ]
        for error in errors {
            #expect(error.errorDescription != nil)
        }
    }
}
