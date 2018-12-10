//
//  MessageFromUnsignedTransaction.swift
//  Zesame iOS
//
//  Created by Alexander Cyon on 2018-09-20.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import EllipticCurveKit

private extension BigNumber {
    func asHexStringLength32(uppercased: Bool = true) -> String {
        var hexString = toString(uppercased: uppercased, radix: 16)
        while hexString.count < 32 {
            hexString = "0\(hexString)"
        }
        return hexString
    }

    func as16BytesLongData() -> Data {
        return Data(hex: asHexStringLength32())
    }
}

func messageFromUnsignedTransaction(_ tx: Transaction, publicKey: PublicKey, hasher: EllipticCurveKit.Hasher = DefaultHasher.sha256) -> Message {

    func formatCodeOrData(_ string: String) -> Data {
        return string.data(using: .utf8)!
    }

    func amountToIntTo16BytesLongData(_ amount: Amount) -> Data {
        return BigNumber(amount.asUInt64).as16BytesLongData()
    }

    let protoTransaction = ProtoTransactionCoreInfo.with {
        $0.version = tx.version
        $0.nonce = tx.payment.nonce.nonce
        $0.toaddr = BigNumber(hexString: tx.payment.recipient.checksummedHex)!.asTrimmedData()
        $0.senderpubkey = publicKey.data.compressed.asByteArray
        $0.amount = amountToIntTo16BytesLongData(tx.payment.amount).asByteArray
        $0.gasprice = amountToIntTo16BytesLongData(tx.payment.gasPrice).asByteArray
        $0.gaslimit = tx.payment.gasLimit.asUInt64
        $0.code = formatCodeOrData(tx.code)
        $0.data = formatCodeOrData(tx.data)

    }

    let protoBinaryData: Data
    do {
        protoBinaryData = try protoTransaction.serializedData()
    } catch {
        fatalError("Incorrect implementation, should be able to serialize into proto binary data")
    }

    return Message(hashedData: protoBinaryData, hashedBy: hasher)
}


public struct SignedTransaction {

    private let signature: String
    private let transaction: Transaction
    private let publicKeyCompressed: String

    init(transaction: Transaction, signedBy publicKey: PublicKey, signature: Signature) {
        self.transaction = transaction
        self.publicKeyCompressed = publicKey.hex.compressed
        self.signature = signature.asHexString()
    }
}

extension SignedTransaction: Encodable {

    enum CodingKeys: String, CodingKey {
        case version, toAddr, nonce, pubKey, amount, gasPrice, gasLimit, code, data, signature
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let tx = transaction
        let p = tx.payment

        try container.encode(tx.version, forKey: .version)
        try container.encode(p.nonce.nonce, forKey: .nonce)
        try container.encode(p.recipient, forKey: .toAddr)
        try container.encode(publicKeyCompressed, forKey: .pubKey)

        let k = CodingKeys.self
        try zip(
            [p.amount, p.gasPrice, p.gasLimit],
            [k.amount, k.gasPrice, k.gasLimit]
        ).forEach { (value, key) in
            try container.encode(value.asUInt64.description, forKey: key)
        }

//        try container.encode(p.amount.asUInt64, forKey: .amount)
//        try container.encode(p.gasPrice.asUInt64, forKey: .gasPrice)
//        try container.encode(p.gasLimit.asUInt64, forKey: .gasLimit)

        try container.encode(tx.code, forKey: .code)
        try container.encode(tx.data, forKey: .data)
        try container.encode(signature, forKey: .signature)

    }
}

public struct Transaction {
    let version: UInt32
    let payment: Payment
    let data: String
    let code: String

    init(payment: Payment, version: UInt32 = 1, data: String = "", code: String = "") {
        self.version = version
        self.payment = payment
        self.data = data
        self.code = code
    }
}

// MARK: - Private format helpers
private extension Amount {
    var asUInt64: UInt64 {
        return UInt64(amount)
    }

    var asByteArray: ByteArray {
        return BigNumber(amount).asTrimmedData().asByteArray
    }
}

private extension Data {
    var asByteArray: ByteArray {
        return ByteArray.with { $0.data = self }
    }
}

private extension UInt64 {
    var asByteArray: ByteArray {
        return BigNumber(self).asTrimmedData().asByteArray
    }
}
