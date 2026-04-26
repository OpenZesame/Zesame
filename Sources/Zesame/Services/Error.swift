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

import Foundation

/// The single error type surfaced by Zesame's public API.
///
/// Underlying transport errors are wrapped via ``Error/API`` so callers can pattern-match on the
/// failure category without reaching for `NSError` codes.
public enum Error: Swift.Error {
    /// Failure from the JSON-RPC transport (request error or timeout).
    case api(API)
    /// The supplied keystore password is shorter than ``Keystore`` requires.
    case keystorePasswordTooShort(provided: Int, minimum: Int)
    /// Wallet/keystore import failed; see ``Error/WalletImport`` for the specific cause.
    case walletImport(WalletImport)
    /// Encrypting a private key into a keystore failed.
    case keystoreExport(Swift.Error)
    /// Decrypting the keystore's private key failed (typically wrong password or corrupt MAC).
    case decryptPrivateKey(Swift.Error)
}

public extension Error {
    /// Failures originating from the JSON-RPC transport layer.
    enum API: Swift.Error {
        /// Wrapped underlying error (URL/network/serialisation).
        case request(Swift.Error)
        /// The polling budget was exhausted before the network reached consensus.
        case timeout
        /// While polling, the node reported the transaction as permanently rejected. Carries the
        /// validator errors and contract exceptions so the caller can surface them to the user
        /// instead of waiting for the timeout.
        case transactionRejected(
            errors: [String: [Int]],
            exceptions: [StatusOfTransactionResponse.TransactionException]
        )
    }

    /// Specific reasons a keystore/private-key import can fail.
    enum WalletImport: Swift.Error {
        /// The address embedded in the keystore is malformed.
        case badAddress
        /// The supplied private-key hex string is not valid hex / not the expected length.
        case badPrivateKeyHex
        /// The supplied private-key bytes were valid hex but rejected by the secp256k1 layer
        /// (e.g. zero key, key ≥ curve order). Carries the underlying error for diagnostics.
        case invalidPrivateKey(Swift.Error)
        /// The keystore JSON could not be decoded as a UTF-8 string.
        case jsonStringDecoding
        /// `JSONDecoder` rejected the keystore payload.
        case jsonDecoding(Swift.DecodingError)
        /// The decoded `Wallet`'s top-level address doesn't match the address embedded in the
        /// keystore — indicates a tampered or hand-edited JSON.
        case walletAddressMismatch
        /// The keystore is well-formed but the password is wrong (MAC mismatch).
        case incorrectPassword
        /// Other keystore-level failure surfaced from the keystore subsystem.
        case keystoreError(Swift.Error)
    }
}
