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

/// The output of a key derivation function (e.g. `scrypt`, `pbkdf2`).
///
/// A `DerivedKey` is the symmetric key obtained by stretching a passphrase through a KDF; it is
/// then split (typically halves) to encrypt the wallet private key and to compute the keystore
/// MAC. Treat it as sensitive material — do not log or persist it outside of memory. Prefer
/// ``symmetricKey`` over the raw ``data`` accessor at use sites that immediately feed CryptoKit:
/// `SymmetricKey` zeroes its backing storage on deinit on Apple platforms.
public struct DerivedKey {
    /// The raw derived bytes. Kept `public` for backward compatibility — new code should reach
    /// for ``symmetricKey`` instead, which keeps the bytes inside CryptoKit's locked-down
    /// `SymmetricKey` allocation rather than a plain `Data` heap buffer.
    public let data: Data

    /// CryptoKit-friendly view onto the same bytes. Useful at AES.GCM / HMAC call sites.
    public var symmetricKey: SymmetricKey {
        SymmetricKey(data: data)
    }

    /// Wraps already-derived bytes. The caller is responsible for ensuring the bytes were produced
    /// by an appropriately-tuned KDF.
    public init(data: Data) {
        self.data = data
    }
}

extension DerivedKey: DataConvertible {
    /// The derived key bytes, exposed for ``DataConvertible`` conformance.
    public var asData: Data {
        data
    }
}
