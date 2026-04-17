import Foundation
import SwiftProtobuf
import Testing
@testable import Zesame

struct ByteArrayTests {
    @Test func initDefault() {
        let bytes = ByteArray()
        #expect(bytes.hasData == false)
        #expect(bytes.data == Data())
    }

    @Test func setAndGetData() {
        var bytes = ByteArray()
        bytes.data = Data([0x01, 0x02])
        #expect(bytes.hasData == true)
        #expect(bytes.data == Data([0x01, 0x02]))
    }

    @Test func clearData() {
        var bytes = ByteArray()
        bytes.data = Data([0x01])
        bytes.clearData()
        #expect(bytes.hasData == false)
        #expect(bytes.data == Data())
    }
}

struct ProtoTransactionCoreInfoTests {
    @Test func initDefault() {
        let tx = ProtoTransactionCoreInfo()
        #expect(tx.hasVersion == false)
        #expect(tx.version == 0)
        #expect(tx.hasNonce == false)
        #expect(tx.nonce == 0)
        #expect(tx.hasToaddr == false)
        #expect(tx.hasAmount == false)
        #expect(tx.hasGasprice == false)
        #expect(tx.hasGaslimit == false)
        #expect(tx.hasCode == false)
        #expect(tx.hasData == false)
        #expect(tx.hasSenderpubkey == false)
    }

    @Test func setFields() {
        var tx = ProtoTransactionCoreInfo()
        tx.version = 65537
        tx.nonce = 1
        tx.toaddr = Data([0xAB])
        tx.gaslimit = 50
        tx.code = Data()
        tx.data = Data()

        #expect(tx.hasVersion == true)
        #expect(tx.version == 65537)
        #expect(tx.hasNonce == true)
        #expect(tx.nonce == 1)
        #expect(tx.hasToaddr == true)
        #expect(tx.hasGaslimit == true)
        #expect(tx.gaslimit == 50)
        #expect(tx.hasCode == true)
        #expect(tx.hasData == true)
    }

    @Test func setByteArrayFields() {
        var tx = ProtoTransactionCoreInfo()
        var amount = ByteArray()
        amount.data = Data([0x00])
        tx.amount = amount
        var gasprice = ByteArray()
        gasprice.data = Data([0x01])
        tx.gasprice = gasprice
        var pubkey = ByteArray()
        pubkey.data = Data([0x02])
        tx.senderpubkey = pubkey

        #expect(tx.hasAmount == true)
        #expect(tx.hasGasprice == true)
        #expect(tx.hasSenderpubkey == true)
    }

    @Test func clearFields() {
        var tx = ProtoTransactionCoreInfo()
        tx.version = 1
        tx.nonce = 2
        tx.clearVersion()
        tx.clearNonce()
        #expect(tx.hasVersion == false)
        #expect(tx.hasNonce == false)

        tx.toaddr = Data([0x01])
        tx.clearToaddr()
        #expect(tx.hasToaddr == false)

        tx.gaslimit = 50
        tx.clearGaslimit()
        #expect(tx.hasGaslimit == false)

        tx.code = Data()
        tx.clearCode()
        #expect(tx.hasCode == false)

        tx.data = Data()
        tx.clearData()
        #expect(tx.hasData == false)

        var amount = ByteArray()
        amount.data = Data([0x01])
        tx.amount = amount
        tx.clearAmount()
        #expect(tx.hasAmount == false)

        var gasprice = ByteArray()
        gasprice.data = Data([0x01])
        tx.gasprice = gasprice
        tx.clearGasprice()
        #expect(tx.hasGasprice == false)

        var pubkey = ByteArray()
        pubkey.data = Data([0x01])
        tx.senderpubkey = pubkey
        tx.clearSenderpubkey()
        #expect(tx.hasSenderpubkey == false)
    }

    @Test func serialization() throws {
        var tx = ProtoTransactionCoreInfo()
        tx.version = 65537
        tx.nonce = 42
        tx.toaddr = Data([0xAB, 0xCD])
        tx.gaslimit = 50
        var amount = ByteArray()
        amount.data = Data([0x00, 0x01])
        tx.amount = amount
        var gasprice = ByteArray()
        gasprice.data = Data([0x02])
        tx.gasprice = gasprice
        var pubkey = ByteArray()
        pubkey.data = Data([0x03])
        tx.senderpubkey = pubkey
        tx.code = Data([0x04])
        tx.data = Data([0x05])

        let serialized = try tx.serializedData()
        #expect(!serialized.isEmpty)

        let decoded = try ProtoTransactionCoreInfo(serializedBytes: serialized)
        #expect(decoded.version == 65537)
        #expect(decoded.nonce == 42)
        #expect(decoded.toaddr == Data([0xAB, 0xCD]))
        #expect(decoded.gaslimit == 50)
        #expect(decoded.amount.data == Data([0x00, 0x01]))
        #expect(decoded.gasprice.data == Data([0x02]))
        #expect(decoded.senderpubkey.data == Data([0x03]))
        #expect(decoded.code == Data([0x04]))
        #expect(decoded.data == Data([0x05]))
    }

    @Test func equality() {
        var tx1 = ProtoTransactionCoreInfo()
        tx1.version = 1
        var tx2 = ProtoTransactionCoreInfo()
        tx2.version = 1
        var tx3 = ProtoTransactionCoreInfo()
        tx3.version = 2
        #expect(tx1 == tx2)
        #expect(tx1 != tx3)
    }

    @Test func isInitialized() {
        var tx = ProtoTransactionCoreInfo()
        #expect(tx.isInitialized == true)
        var bytes = ByteArray()
        bytes.data = Data([0x01])
        tx.senderpubkey = bytes
        #expect(tx.isInitialized == true)
    }
}

// MARK: - ByteArray serialization

struct ByteArraySerializationTests {
    @Test func serialization() throws {
        var bytes = ByteArray()
        bytes.data = Data([0xDE, 0xAD, 0xBE, 0xEF])
        let serialized = try bytes.serializedData()
        #expect(!serialized.isEmpty)
        let decoded = try ByteArray(serializedBytes: serialized)
        #expect(decoded.data == Data([0xDE, 0xAD, 0xBE, 0xEF]))
    }

    @Test func serializeWithEmptyData() throws {
        var bytes = ByteArray()
        bytes.data = Data() // empty but explicitly set → isInitialized = true
        let serialized = try bytes.serializedData()
        let decoded = try ByteArray(serializedBytes: serialized)
        // Empty bytes field is omitted in protobuf wire format → hasData becomes false after roundtrip
        #expect(decoded.data == Data())
    }

    @Test func equality() {
        var bytes1 = ByteArray()
        bytes1.data = Data([0x01])
        var bytes2 = ByteArray()
        bytes2.data = Data([0x01])
        var bytes3 = ByteArray()
        bytes3.data = Data([0x02])
        #expect(bytes1 == bytes2)
        #expect(bytes1 != bytes3)
    }

    @Test func isInitializedWhenDataSet() {
        var bytes = ByteArray()
        #expect(bytes.isInitialized == false)
        bytes.data = Data([0x01])
        #expect(bytes.isInitialized == true)
    }
}

// MARK: - ProtoTransaction

struct ProtoTransactionTests {
    @Test func initDefault() {
        let tx = ProtoTransaction()
        #expect(tx.hasTranid == false)
        #expect(tx.tranid == Data())
        #expect(tx.hasInfo == false)
        #expect(tx.hasSignature == false)
    }

    @Test func setFields() {
        var tx = ProtoTransaction()
        tx.tranid = Data([0xAB])
        var info = ProtoTransactionCoreInfo()
        info.version = 1
        tx.info = info
        var sig = ByteArray()
        sig.data = Data([0xFF])
        tx.signature = sig

        #expect(tx.hasTranid == true)
        #expect(tx.tranid == Data([0xAB]))
        #expect(tx.hasInfo == true)
        #expect(tx.info.version == 1)
        #expect(tx.hasSignature == true)
        #expect(tx.signature.data == Data([0xFF]))
    }

    @Test func clearFields() {
        var tx = ProtoTransaction()
        tx.tranid = Data([0x01])
        tx.clearTranid()
        #expect(tx.hasTranid == false)

        var info = ProtoTransactionCoreInfo()
        info.version = 1
        tx.info = info
        tx.clearInfo()
        #expect(tx.hasInfo == false)

        var sig = ByteArray()
        sig.data = Data([0x01])
        tx.signature = sig
        tx.clearSignature()
        #expect(tx.hasSignature == false)
    }

    @Test func serialization() throws {
        var tx = ProtoTransaction()
        tx.tranid = Data([0x01, 0x02])
        var info = ProtoTransactionCoreInfo()
        info.version = 65537
        info.nonce = 5
        tx.info = info
        var sig = ByteArray()
        sig.data = Data([0xAA, 0xBB])
        tx.signature = sig

        let serialized = try tx.serializedData()
        #expect(!serialized.isEmpty)
        let decoded = try ProtoTransaction(serializedBytes: serialized)
        #expect(decoded.tranid == Data([0x01, 0x02]))
        #expect(decoded.info.version == 65537)
        #expect(decoded.signature.data == Data([0xAA, 0xBB]))
    }

    @Test func equality() {
        var tx1 = ProtoTransaction()
        tx1.tranid = Data([0x01])
        var tx2 = ProtoTransaction()
        tx2.tranid = Data([0x01])
        var tx3 = ProtoTransaction()
        tx3.tranid = Data([0x02])
        #expect(tx1 == tx2)
        #expect(tx1 != tx3)
    }

    @Test func isInitialized() {
        let tx = ProtoTransaction()
        #expect(tx.isInitialized == true)
    }
}

// MARK: - ProtoTransactionReceipt

struct ProtoTransactionReceiptTests {
    @Test func initDefault() {
        let r = ProtoTransactionReceipt()
        #expect(r.hasReceipt == false)
        #expect(r.receipt == Data())
        #expect(r.hasCumgas == false)
        #expect(r.cumgas == 0)
    }

    @Test func setFields() {
        var r = ProtoTransactionReceipt()
        r.receipt = Data([0x01])
        r.cumgas = 1000

        #expect(r.hasReceipt == true)
        #expect(r.receipt == Data([0x01]))
        #expect(r.hasCumgas == true)
        #expect(r.cumgas == 1000)
    }

    @Test func clearFields() {
        var r = ProtoTransactionReceipt()
        r.receipt = Data([0x01])
        r.clearReceipt()
        #expect(r.hasReceipt == false)

        r.cumgas = 100
        r.clearCumgas()
        #expect(r.hasCumgas == false)
    }

    @Test func serialization() throws {
        var r = ProtoTransactionReceipt()
        r.receipt = Data([0xDE, 0xAD])
        r.cumgas = 9999

        let serialized = try r.serializedData()
        #expect(!serialized.isEmpty)
        let decoded = try ProtoTransactionReceipt(serializedBytes: serialized)
        #expect(decoded.receipt == Data([0xDE, 0xAD]))
        #expect(decoded.cumgas == 9999)
    }

    @Test func equality() {
        var r1 = ProtoTransactionReceipt()
        r1.cumgas = 100
        var r2 = ProtoTransactionReceipt()
        r2.cumgas = 100
        var r3 = ProtoTransactionReceipt()
        r3.cumgas = 200
        #expect(r1 == r2)
        #expect(r1 != r3)
    }
}

// MARK: - ProtoTransactionWithReceipt

struct ProtoTransactionWithReceiptTests {
    @Test func initDefault() {
        let twr = ProtoTransactionWithReceipt()
        #expect(twr.hasTransaction == false)
        #expect(twr.hasReceipt == false)
    }

    @Test func setFields() {
        var twr = ProtoTransactionWithReceipt()
        var tx = ProtoTransaction()
        tx.tranid = Data([0x01])
        twr.transaction = tx
        var receipt = ProtoTransactionReceipt()
        receipt.cumgas = 500
        twr.receipt = receipt

        #expect(twr.hasTransaction == true)
        #expect(twr.transaction.tranid == Data([0x01]))
        #expect(twr.hasReceipt == true)
        #expect(twr.receipt.cumgas == 500)
    }

    @Test func clearFields() {
        var twr = ProtoTransactionWithReceipt()
        var tx = ProtoTransaction()
        tx.tranid = Data([0x01])
        twr.transaction = tx
        twr.clearTransaction()
        #expect(twr.hasTransaction == false)

        var receipt = ProtoTransactionReceipt()
        receipt.cumgas = 100
        twr.receipt = receipt
        twr.clearReceipt()
        #expect(twr.hasReceipt == false)
    }

    @Test func serialization() throws {
        var twr = ProtoTransactionWithReceipt()
        var tx = ProtoTransaction()
        tx.tranid = Data([0xAB])
        twr.transaction = tx
        var receipt = ProtoTransactionReceipt()
        receipt.cumgas = 777
        twr.receipt = receipt

        let serialized = try twr.serializedData()
        #expect(!serialized.isEmpty)
        let decoded = try ProtoTransactionWithReceipt(serializedBytes: serialized)
        #expect(decoded.transaction.tranid == Data([0xAB]))
        #expect(decoded.receipt.cumgas == 777)
    }

    @Test func equality() {
        var twr1 = ProtoTransactionWithReceipt()
        var r1 = ProtoTransactionReceipt()
        r1.cumgas = 100
        twr1.receipt = r1

        var twr2 = ProtoTransactionWithReceipt()
        var r2 = ProtoTransactionReceipt()
        r2.cumgas = 100
        twr2.receipt = r2

        var twr3 = ProtoTransactionWithReceipt()
        #expect(twr1 == twr2)
        #expect(twr1 != twr3)
    }

    @Test func isInitialized() {
        let twr = ProtoTransactionWithReceipt()
        #expect(twr.isInitialized == true)
    }
}
