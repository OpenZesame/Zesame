//
// MIT License
//
// Copyright (c) 2018-2026 Open Zesame (https://github.com/OpenZesame)
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

import CryptoKit
import Foundation

/// Builds the canonical signing payload for a Zilliqa transaction.
///
/// The payload is the SHA-256 (or whatever ``HashFunction`` is supplied) of the protobuf
/// serialisation of ``ProtoTransactionCoreInfo``, populated from `tx`. Numeric amounts are
/// padded to 16 bytes to match the reference implementation; deviating from this exact byte
/// layout produces signatures the network will reject.
///
/// - Parameters:
///   - tx: The unsigned transaction whose core fields will be hashed.
///   - publicKey: The signer's compressed secp256k1 public key, embedded into the payload.
///   - hasher: Hash function instance — typically `SHA256()`.
/// - Returns: The digest bytes that should be passed to the signing function.
func messageFromUnsignedTransaction(
    _ tx: Transaction,
    publicKey: PublicKey,
    hasher: some HashFunction
) throws -> Data {
    func formatCodeOrData(_ string: String) -> Data {
        string.data(using: .utf8)!
    }

    let protoTransaction = ProtoTransactionCoreInfo.with {
        $0.version = tx.version.value
        $0.nonce = tx.payment.nonce.nonce
        // The recipient address is hex-decoded into raw bytes; casing is irrelevant for
        // `Data(hex:)`. Lowercased here only to match the canonical wire form documented for the
        // Zilliqa reference signer.
        $0.toaddr = Data(hex: tx.payment.recipient.asString.lowercased())
        $0.senderpubkey = publicKey.compressedRepresentation.asByteArray
        $0.amount = tx.payment.amount.as16BytesLongArray
        $0.gasprice = tx.payment.gasPrice.as16BytesLongArray
        $0.gaslimit = UInt64(tx.payment.gasLimit)
        if let code = tx.code {
            $0.code = formatCodeOrData(code)
        }
        if let data = tx.data {
            $0.data = formatCodeOrData(data)
        }
    }

    let serialized = try protoTransaction.serializedData()
    var hashFunction = hasher
    hashFunction.update(data: serialized)
    return Data(hashFunction.finalize())
}

// MARK: - Private format helpers

private extension BigInt {
    /// Big-endian hex serialisation, optionally left-padded with zero bytes so the result is at
    /// least `minByteCount` bytes long.
    func asData(minByteCount: Int? = nil) -> Data {
        var hexString = String(magnitude, radix: 16)
        if let minByteCount {
            let minStringLength = 2 * minByteCount
            while hexString.count < minStringLength {
                hexString = "0" + hexString
            }
        }
        return Data(hex: hexString)
    }
}

import BigInt

private extension ExpressibleByAmount {
    /// Renders the amount in Qa as zero-padded big-endian bytes.
    func asData(minByteCount: Int? = nil) -> Data {
        qa.asData(minByteCount: minByteCount)
    }

    /// The amount wrapped in a protobuf ``ByteArray``.
    var asByteArray: ByteArray {
        asData().asByteArray
    }

    /// The amount as a 16-byte (uint128) protobuf ``ByteArray`` — the wire layout the network
    /// expects for `amount` and `gasPrice` fields. Traps if the magnitude requires more than 16
    /// bytes; that's only possible if `GasPrice.maxInQa` (or a similar bound) has been raised
    /// past `2^128`, which the network would reject anyway, so refuse to sign.
    var as16BytesLongArray: ByteArray {
        let bytes = asData(minByteCount: 16)
        precondition(
            bytes.count == 16,
            "Amount/gasPrice magnitude exceeds 16 bytes (uint128) — would produce a transaction the network will reject"
        )
        return bytes.asByteArray
    }
}

private extension Data {
    /// Wraps the bytes in a protobuf ``ByteArray`` message.
    var asByteArray: ByteArray {
        ByteArray.with { $0.data = self }
    }
}
