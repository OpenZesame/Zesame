import Foundation
import Testing
@testable import Zesame

struct UnboundArithmeticTests {
    @Test func qaAddition() {
        let a = Qa(qa: 100)
        let b = Qa(qa: 50)
        let c = a + b
        #expect(c.qa == 150)
    }

    @Test func qaSubtraction() {
        let a = Qa(qa: 100)
        let b = Qa(qa: 30)
        let c = a - b
        #expect(c.qa == 70)
    }

    @Test func qaMultiplication() {
        let a = Qa(qa: 10)
        let b = Qa(qa: 5)
        let c = a * b
        #expect(c.qa == 50)
    }

    @Test func qaAdditionHeterogeneous() {
        let a = Qa(qa: 100)
        let b = Qa(qa: 50)
        let c: Qa = a + b
        #expect(c.qa == 150)
    }

    @Test func qaSubtractionHeterogeneous() {
        let a = Qa(qa: 200)
        let b = Qa(qa: 50)
        let c: Qa = a - b
        #expect(c.qa == 150)
    }
}

struct BoundArithmeticTests {
    @Test func amountAddition() throws {
        let a = try Amount(qa: "1000")
        let b = try Amount(qa: "500")
        let c = try a + b
        #expect(c.qaString == "1500")
    }

    @Test func amountSubtraction() throws {
        let a = try Amount(qa: "1000")
        let b = try Amount(qa: "300")
        let c = try a - b
        #expect(c.qaString == "700")
    }

    @Test func amountMultiplication() throws {
        let a = try Amount(qa: "10")
        let b = try Amount(qa: "5")
        let c = try a * b
        #expect(c.qaString == "50")
    }

    @Test func amountAddHeterogeneous() throws {
        let a = try Amount(qa: "1000")
        let b = Qa(qa: 500)
        let c: Amount = try a + b
        #expect(c.qaString == "1500")
    }

    @Test func amountSubtractHeterogeneous() throws {
        let a = try Amount(qa: "1000")
        let b = Qa(qa: 200)
        let c: Amount = try a - b
        #expect(c.qaString == "800")
    }
}

struct HeterogeneousComparisonTests {
    @Test func equalQaValues() {
        let a = Qa(qa: 100)
        let b = Qa(qa: 100)
        #expect(a == b)
    }

    @Test func notEqualQaValues() {
        let a = Qa(qa: 100)
        let b = Qa(qa: 200)
        #expect(a != b)
    }

    @Test func lessThan() {
        let a = Qa(qa: 50)
        let b = Qa(qa: 100)
        #expect(a < b)
    }

    @Test func greaterThan() {
        let a = Qa(qa: 200)
        let b = Qa(qa: 100)
        #expect(a > b)
    }

    @Test func lessThanOrEqual() {
        let a = Qa(qa: 100)
        let b = Qa(qa: 100)
        let c = Qa(qa: 50)
        #expect(a <= b)
        #expect(c <= a)
    }

    @Test func greaterThanOrEqual() {
        let a = Qa(qa: 100)
        let b = Qa(qa: 100)
        let c = Qa(qa: 200)
        #expect(a >= b)
        #expect(c >= a)
    }

    @Test func crossTypeComparison() throws {
        let amount = try Amount(qa: "1000")
        let qa = Qa(qa: 1000)
        #expect(amount == qa)
        #expect(amount <= qa)
        #expect(amount >= qa)
    }
}

struct DebugStringTests {
    @Test func debugDescription() throws {
        let amount = try Amount(qa: "1000000000000")
        let desc = amount.debugDescription
        #expect(desc.contains("qa"))
        #expect(desc.contains("Zils"))
    }

    @Test func zilString() throws {
        let amount = try Amount(zil: "1")
        let s = amount.zilString
        #expect(s == "1")
    }

    @Test func liString() throws {
        let amount = try Amount(qa: "1000000")
        let s = amount.liString
        #expect(!s.isEmpty)
    }

    @Test func qaString() throws {
        let amount = try Amount(qa: "42")
        #expect(amount.qaString == "42")
    }

    @Test func asStringInQa() throws {
        let amount = try Amount(qa: "100")
        let s = amount.asString(in: .qa)
        #expect(s == "100")
    }

    @Test func asStringInZil() throws {
        let amount = try Amount(zil: "5")
        let s = amount.asString(in: .zil)
        #expect(s == "5")
    }

    @Test func asStringInLi() throws {
        let amount = try Amount(zil: "1")
        let s = amount.asString(in: .li)
        #expect(!s.isEmpty)
    }

    @Test func asStringWithRounding() throws {
        let amount = try Amount(zil: "1")
        let s = amount.asString(in: .zil, roundingIfNeeded: .plain, roundingNumberOfDigits: 2)
        #expect(!s.isEmpty)
    }

    @Test func asStringWithMinFractionDigits() throws {
        let amount = try Amount(zil: "1")
        let s = amount.asString(in: .zil, roundingIfNeeded: nil, minFractionDigits: 2)
        #expect(!s.isEmpty)
    }
}

struct ValidateTests {
    @Test func validateBound() throws {
        let validQa: Amount.Magnitude = 1000
        let result = try Amount.validate(value: validQa)
        #expect(result == validQa)
    }

    @Test func validateBoundTooLow() {
        #expect(throws: (any Swift.Error).self) {
            _ = try Amount.validate(value: 0 - 1)
        }
    }

    @Test func validateUnbound() {
        let val: Qa.Magnitude = 9999
        let result = (try? Qa.validate(value: val))!
        #expect(result == val)
    }

    @Test func validateGasPriceBounds() throws {
        let validGasPrice = GasPrice.minInQa
        let gp = try GasPrice(qa: validGasPrice)
        #expect(gp.qa == validGasPrice)
    }

    @Test func validateGasPriceTooLow() {
        #expect(throws: (any Swift.Error).self) {
            _ = try GasPrice(qa: GasPrice.minInQa - 1)
        }
    }

    @Test func validateGasPriceTooHigh() {
        #expect(throws: (any Swift.Error).self) {
            _ = try GasPrice(qa: GasPrice.maxInQa + 1)
        }
    }
}

struct GasPriceTests2 {
    @Test func defaultMinAndMax() {
        #expect(GasPrice.minInQaDefault == 100_000_000_000)
        #expect(GasPrice.maxInQaDefault == 100_000_000_000_000)
    }

    @Test func unitIsQa() {
        #expect(GasPrice.unit == .qa)
    }
}

struct PaymentTests {
    @Test func initSuccess() throws {
        let recipient = try LegacyAddress(string: "1234567890123456789012345678901234567890")
        let amount = try Amount(qa: "1000")
        let gasPrice = GasPrice.min
        let payment = try Payment(
            to: recipient,
            amount: amount,
            gasLimit: GasLimit.minimum,
            gasPrice: gasPrice,
            nonce: 0
        )
        #expect(payment.nonce.nonce == 1) // nonce gets incremented by 1
    }

    @Test func initGasLimitTooLowThrows() throws {
        let recipient = try LegacyAddress(string: "1234567890123456789012345678901234567890")
        let amount = try Amount(qa: "1000")
        let gasPrice = GasPrice.min
        #expect(throws: (any Swift.Error).self) {
            // Below minimum gasLimit (GasLimit is Int, minimum is 50)
            _ = try Payment(
                to: recipient,
                amount: amount,
                gasLimit: GasLimit.minimum - 1,
                gasPrice: gasPrice
            )
        }
    }

    @Test func withMinimumGasLimit() throws {
        let recipient = try LegacyAddress(string: "1234567890123456789012345678901234567890")
        let amount = try Amount(qa: "1000")
        let gasPrice = GasPrice.min
        let payment = Payment.withMinimumGasLimit(to: recipient, amount: amount, gasPrice: gasPrice, nonce: 0)
        #expect(payment.gasLimit == GasLimit.minimum)
    }

    @Test func estimatedTransactionFee() throws {
        let gasPrice = GasPrice.min
        let fee = try Payment.estimatedTotalTransactionFee(gasPrice: gasPrice)
        #expect(fee.qa > 0)
    }

    @Test func estimatedTotalCost() throws {
        let amount = try Amount(qa: "1000")
        let gasPrice = GasPrice.min
        let total = try Payment.estimatedTotalCostOfTransaction(amount: amount, gasPrice: gasPrice)
        #expect(total.qa > amount.qa)
    }
}
