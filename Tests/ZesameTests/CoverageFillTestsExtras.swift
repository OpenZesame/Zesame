import BigInt
import Combine
import CryptoKit
import Foundation
import Testing
@testable import Zesame

// MARK: - ExpressibleByAmount+Bound: init(valid:) and Double-only parse

struct ExpressibleByAmountBoundExtraTests {
    @Test func boundInitValidConstructsAmount() {
        let amount = Amount(valid: 5) // 5 Zil = 5e12 Qa, well within bounds
        #expect(amount.qa == 5_000_000_000_000)
    }

    @Test func doubleFromStringFromCurrentLocale() {
        let parsed = Double.fromString("12.5")
        #expect(parsed == 12.5)
    }

    @Test func doubleFromStringReturnsNilOnGarbage() {
        let parsed = Double.fromString("not-a-double-anywhere")
        #expect(parsed == nil)
    }
}

// MARK: - Heterogeneous comparison & arithmetic gaps

struct HeterogeneousComparisonGapTests {
    @Test func notEqualHeterogeneous() throws {
        let a = try Amount(qa: "1")
        let b = Qa(qa: 2)
        #expect((a != b) == true)
    }

    @Test func unboundHeterogeneousSubtraction() {
        let a = Zil(qa: 100)
        let b = Qa(qa: 30)
        let result: Zil = a - b
        #expect(result.qa == 70)
    }
}

// MARK: - ExpressibleByAmount+UnitConversion: exponent ordering branches

struct UnitConversionBranchTests {
    @Test func decimalValueExponentEqualReturnsSame() throws {
        let amount = try Amount(qa: "1000")
        let decimal = amount.decimalValue(in: .qa, rounding: nil)
        #expect(decimal == Decimal(1000))
    }

    @Test func decimalValueExponentDownscalesToHigherUnit() throws {
        let amount = try Amount(qa: "1000000000000")
        let decimal = amount.decimalValue(in: .zil, rounding: nil)
        #expect(decimal == Decimal(1))
    }
}

// MARK: - Bech32 decoding error coverage

struct Bech32DecodingErrorPathsTests {
    @Test func invalidCharacterInDataPartThrows() {
        #expect(throws: Bech32.DecodingError.self) {
            _ = try Bech32.decode("zil1bbbbbbb")
        }
    }
}

// MARK: - String+AmountValidation: integer-only branch

struct StringAmountValidationIntegerBranchTests {
    @Test func integerWithoutSeparatorReturnsZeroDecimalPlaces() {
        let result = "12345".countDecimalPlaces()
        #expect(result == 0)
    }
}

// MARK: - Polling Delay/Count statics

struct PollingDelayCountStaticsTests {
    @Test func threeSecondsDelayRawValue() {
        #expect(Polling.Delay.threeSeconds.rawValue == 3)
    }

    @Test func fiveSecondsDelayRawValue() {
        #expect(Polling.Delay.fiveSeconds.rawValue == 5)
    }

    @Test func sevenSecondsDelayRawValue() {
        #expect(Polling.Delay.sevenSeconds.rawValue == 7)
    }

    @Test func tenSecondsDelayRawValue() {
        #expect(Polling.Delay.tenSeconds.rawValue == 10)
    }

    @Test func twentySecondsDelayRawValue() {
        #expect(Polling.Delay.twentySeconds.rawValue == 20)
    }

    @Test func onceCountRawValue() {
        #expect(Polling.Count.once.rawValue == 1)
    }

    @Test func twiceCountRawValue() {
        #expect(Polling.Count.twice.rawValue == 2)
    }

    @Test func threeTimesCountRawValue() {
        #expect(Polling.Count.threeTimes.rawValue == 3)
    }

    @Test func fiveTimesCountRawValue() {
        #expect(Polling.Count.fiveTimes.rawValue == 5)
    }

    @Test func tenTimesCountRawValue() {
        #expect(Polling.Count.tenTimes.rawValue == 10)
    }
}

// MARK: - Address.swift equality across encodings

struct AddressEqualityAcrossEncodingsTests {
    @Test func legitimateBech32AddressesCompareEqual() {
        let a: Address = "zil1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq9yf6pz"
        let b: Address = "zil1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq9yf6pz"
        #expect(a == b)
    }

    @Test func bech32AndLegacyOfSameAccountCompareEqual() throws {
        let legacy = try LegacyAddress(string: "1234567890123456789012345678901234567890")
        let bech32 = try Bech32Address(ethStyleAddress: legacy)
        #expect(Address.legacy(legacy) == Address.bech32(bech32))
    }
}

// MARK: - Payment boundary at total supply

struct PaymentBoundaryTests {
    @Test func estimatedTotalCostAtMaxAmountThrowsTooLarge() throws {
        let oneQaBelowMax = try Amount(qa: Amount.maxInQa - 1)
        let lowestPrice = try GasPrice(qa: GasPrice.minInQaDefault)
        #expect(throws: AmountError<Amount>.self) {
            _ = try Payment.estimatedTotalCostOfTransaction(
                amount: oneQaBelowMax,
                gasPrice: lowestPrice,
                gasLimit: GasLimit.minimum
            )
        }
    }
}

// MARK: - Bech32Address: bech32DataEmpty + incorrectLength

struct Bech32AddressInternalErrorTests {
    @Test func toChecksummedThrowsBech32DataEmptyOnNilExcludingChecksum() {
        let dataPart = Bech32Address.DataPart(
            excludingChecksum: nil,
            checksum: Bech32Address.DataPart.Bech32Data(Data(repeating: 0, count: 6))
        )
        let bech32 = Bech32Address(network: .mainnet, dataPart: dataPart)
        #expect(throws: Address.Error.self) {
            _ = try bech32.toChecksummedLegacyAddress()
        }
    }

    @Test func toChecksummedThrowsIncorrectLengthOnWrongDataLength() {
        let tooShort = Bech32Address.DataPart.Bech32Data(Data(repeating: 0, count: 4))
        let dataPart = Bech32Address.DataPart(
            excludingChecksum: tooShort,
            checksum: Bech32Address.DataPart.Bech32Data(Data(repeating: 0, count: 6))
        )
        let bech32 = Bech32Address(network: .mainnet, dataPart: dataPart)
        #expect(throws: Address.Error.self) {
            _ = try bech32.toChecksummedLegacyAddress()
        }
    }
}

// MARK: - KeyRestoration: jsonStringDecoding via incompatible encoding

struct KeyRestorationStringEncodingTests {
    @Test func nonAsciiStringWithAsciiEncodingThrowsJsonStringDecoding() {
        let emoji = "🌍"
        #expect(throws: Zesame.Error.self) {
            _ = try KeyRestoration(keyStoreJSONString: emoji, encodedBy: .ascii, encryptedBy: "apabanan")
        }
    }
}

// MARK: - ExpressibleByAmount+Validate via fake protocol-composition types

/// Bounded only above; implements the `NoLowerbound` `-` operator non-throwing.
private struct UpperOnlyAmount: ExpressibleByAmount, Upperbound, NoLowerbound {
    typealias Magnitude = BigInt
    static let unit: Zesame.Unit = .qa
    static let maxInQa: Magnitude = 1000
    let qa: Magnitude
    init(qa: Magnitude) throws {
        self.qa = try Self.validate(value: qa)
    }

    static func - (
        lhs: Self,
        rhs: Self
    ) -> Self {
        try! Self(qa: lhs.qa - rhs.qa)
    }
}

/// Bounded only below; implements the `NoUpperbound` `+`/`*` operators non-throwing.
private struct LowerOnlyAmount: ExpressibleByAmount, Lowerbound, NoUpperbound {
    typealias Magnitude = BigInt
    static let unit: Zesame.Unit = .qa
    static let minInQa: Magnitude = 10
    let qa: Magnitude
    init(qa: Magnitude) throws {
        self.qa = try Self.validate(value: qa)
    }

    static func + (
        lhs: Self,
        rhs: Self
    ) -> Self {
        try! Self(qa: lhs.qa + rhs.qa)
    }

    static func * (
        lhs: Self,
        rhs: Self
    ) -> Self {
        try! Self(qa: lhs.qa * rhs.qa)
    }
}

struct ValidateProtocolCompositionTests {
    @Test func upperOnlyRejectsValueAboveMax() {
        #expect(throws: AmountError<UpperOnlyAmount>.self) {
            _ = try UpperOnlyAmount(qa: 5000)
        }
    }

    @Test func upperOnlyAcceptsValueAtOrBelowMax() throws {
        let amount = try UpperOnlyAmount(qa: 500)
        #expect(amount.qa == 500)
    }

    @Test func lowerOnlyRejectsValueBelowMin() {
        #expect(throws: AmountError<LowerOnlyAmount>.self) {
            _ = try LowerOnlyAmount(qa: 5)
        }
    }

    @Test func lowerOnlyAcceptsValueAtOrAboveMin() throws {
        let amount = try LowerOnlyAmount(qa: 100)
        #expect(amount.qa == 100)
    }
}

// MARK: - Data+Hex: odd-length pad

struct DataHexOddLengthTests {
    @Test func oddLengthHexPadsLeadingZero() {
        let data = Data(hex: "abc")
        #expect(data == Data([0x0A, 0xBC]))
    }
}

// MARK: - ExpressibleByAmount+Unbound: init(valid:)

struct UnboundInitValidTests {
    @Test func unboundInitValidWrapsLikeRegularInit() {
        let zil = Zil(valid: 7)
        #expect(zil.qa == 7_000_000_000_000)
    }
}

// MARK: - ExpressibleByAmount+UnitConversion: divide branch

struct UnitConversionDivideBranchTests {
    @Test func expressDoubleTargetingHigherUnitDivides() {
        let result = Qa.express(double: 1_000_000_000_000.0, in: .zil)
        #expect(result == 1)
    }
}

// MARK: - Keystore+Wallet+Import: corrupt sealed-box

struct KeystoreCorruptSealedBoxTests {
    @Test func corruptCiphertextThrowsOnDecrypt() throws {
        let privateKey = PrivateKey()
        let goodKeystore = try Keystore.from(privateKey: privateKey, encryptBy: "apabanan", kdf: .pbkdf2)
        let tamperedHex = String(repeating: "ff", count: 32)
        let tamperedCrypto = try Keystore.Crypto(
            cipherParameters: goodKeystore.crypto.cipherParameters,
            encryptedPrivateKeyHex: tamperedHex,
            kdf: goodKeystore.crypto.kdf,
            kdfParams: goodKeystore.crypto.keyDerivationFunctionParameters
        )
        let tamperedKeystore = Keystore(address: goodKeystore.address, crypto: tamperedCrypto)
        #expect(throws: Zesame.Error.self) {
            _ = try tamperedKeystore.decryptPrivateKey(encryptedBy: "apabanan")
        }
    }
}

// MARK: - ExpressibleByAmount+Bound: Double-only string parse path

struct ExpressibleByAmountBoundDoubleParseTests {
    @Test func zilStringWithFractionTakesDoubleParseBranch() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        let amount = try Amount(zil: "0\(decSep)5")
        #expect(amount.qa == 500_000_000_000)
    }
}

// MARK: - ExpressibleByAmount+Unbound: nonNumericString throw

struct ExpressibleByAmountUnboundNonNumericTests {
    @Test func zilTrimmingNonNumericThrows() {
        #expect(throws: AmountError<Zil>.self) {
            _ = try Zil(trimming: "totally not a number")
        }
    }
}

// MARK: - ExpressibleByAmount+CustomDebug: trailing-zero stripping

struct ExpressibleByAmountDebugTrailingZerosTests {
    @Test func formatStripsTrailingZerosFromAsString() throws {
        let decSep = Locale.current.decimalSeparatorForSure
        let amount = try Amount(zil: "1\(decSep)5")
        let str = amount.asString(in: .zil)
        #expect(!str.hasSuffix("0"))
    }
}

// MARK: - LegacyAddress+Validation: trailing block continuation

struct LegacyAddressValidationContinuationTests {
    @Test func checksummingPreservesNonLetterCharacters() throws {
        // String with all digits exercises the non-letter-character branch in the checksum loop.
        let allDigits = "1234567890" + "1234567890" + "1234567890" + "1234567890"
        let address = try LegacyAddress(string: allDigits)
        #expect(address.asString == allDigits)
    }
}

// MARK: - Bech32Address.init(stringLiteral:) success path

struct Bech32AddressStringLiteralTests {
    @Test func validLiteralConstructs() {
        let bech32: Bech32Address = "zil1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq9yf6pz"
        #expect(bech32.humanReadablePrefix == "zil")
    }
}

// MARK: - SecureRandom failure path via injected provider

struct SecureRandomFailureTests {
    @Test func failingProviderSurfacesNSError() {
        let failingProvider: RandomBytesProvider = { _, _ in -50 } // errSecParam
        #expect(throws: NSError.self) {
            _ = try securelyGenerateBytes(count: 32, provider: failingProvider)
        }
    }

    @Test func defaultProviderSucceeds() throws {
        let bytes = try securelyGenerateBytes(count: 16)
        #expect(bytes.count == 16)
    }
}

// MARK: - Combine + ZilliqaService non-Zesame error wrapping

private struct ThrowingPBKDF2Error: Swift.Error {}

private struct ThrowingApiClient: APIClient, @unchecked Sendable {
    func send<Response: Decodable>(method _: RPCMethod<Response>) async throws -> Response {
        throw ThrowingPBKDF2Error()
    }
}

struct CombineNonZesameErrorTests {
    /// Drives a non-Zesame error through `callAsync`, exercising the `.api(.request(error))`
    /// wrap branch in `Combine+ZilliqaService.swift`.
    @Test func nonZesameErrorWrappedByCombineCallAsync() async {
        let service = DefaultZilliqaService(apiClient: ThrowingApiClient())
        var cancellable: AnyCancellable?
        let publisher: AnyPublisher<NetworkResponse, Zesame.Error> = service.combine.getNetworkFromAPI()
        await withCheckedContinuation { continuation in
            cancellable = publisher.sink(
                receiveCompletion: { completion in
                    if case .failure = completion { continuation.resume() }
                },
                receiveValue: { _ in }
            )
        }
        _ = cancellable
    }
}
