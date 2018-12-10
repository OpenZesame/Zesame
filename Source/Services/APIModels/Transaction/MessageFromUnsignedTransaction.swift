//
//  MessageFromUnsignedTransaction.swift
//  Zesame iOS
//
//  Created by Alexander Cyon on 2018-09-20.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import EllipticCurveKit

func messageFromUnsignedTransaction(_ tx: Transaction, publicKey: PublicKey, hasher: EllipticCurveKit.Hasher = DefaultHasher.sha256) -> Message {

    func formatCodeOrData(_ string: String) -> Data {
        return string.data(using: .utf8)!
    }

    let protoTransaction = ProtoTransactionCoreInfo.with {
        $0.version = tx.version
        $0.nonce = tx.payment.nonce.nonce
        $0.toaddr = BigNumber(hexString: tx.payment.recipient.checksummedHex)!.asTrimmedData()
        $0.senderpubkey = publicKey.data.compressed.asByteArray
        $0.amount = tx.payment.amount.as16BytesLongArray
        $0.gasprice = tx.payment.gasPrice.as16BytesLongArray
        $0.gaslimit = tx.payment.gasLimit.asUInt64
        $0.code = formatCodeOrData(tx.code)
        $0.data = formatCodeOrData(tx.data)
    }

    return Message(hashedData: try! protoTransaction.serializedData(), hashedBy: hasher)
}

// MARK: - Private format helpers
private extension Amount {
    var asUInt64: UInt64 {
        return UInt64(amount)
    }

    var asByteArray: ByteArray {
        return BigNumber(amount).asTrimmedData().asByteArray
    }

    var as16BytesLongArray: ByteArray {
        return BigNumber(asUInt64).as16BytesLongData().asByteArray
    }
}

private extension Data {
    var asByteArray: ByteArray {
        return ByteArray.with { $0.data = self }
    }
}

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
