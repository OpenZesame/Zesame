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

import CommonCrypto
import CryptoKit
import Foundation

/// PBKDF2-HMAC-SHA512 key deriver. Currently the only supported KDF — the `kdf` parameter is
/// reserved for forward compatibility once additional KDFs are added.
public struct AnyKeyDeriving: KeyDeriving {
    private let kdfParams: KDFParams

    /// Captures the KDF parameters for later derivation. The `kdf` argument is ignored today and
    /// kept for source-stability when more KDFs are added.
    public init(
        kdf _: KDF = .pbkdf2,
        kdfParams: KDFParams
    ) {
        self.kdfParams = kdfParams
    }

    /// Stretches `password` into a ``SymmetricKey`` via PBKDF2-HMAC-SHA512 using the configured
    /// salt, iteration count, and output length.
    ///
    /// - Throws: ``Zesame/Error/walletImport(_:)`` (`.keystoreError`) on any CommonCrypto failure.
    public func deriveKey(password: String) throws -> SymmetricKey {
        let passwordBytes = Array(password.utf8)
        let saltBytes = Array(kdfParams.salt)
        let keyLength = kdfParams.derivedKeyLength
        var derivedKeyBytes = [UInt8](repeating: 0, count: keyLength)

        let status = CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            passwordBytes, passwordBytes.count,
            saltBytes, saltBytes.count,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
            UInt32(kdfParams.iterations),
            &derivedKeyBytes,
            keyLength
        )
        guard status == kCCSuccess else {
            throw Zesame.Error.walletImport(
                .keystoreError(NSError(domain: "PBKDF2", code: Int(status), userInfo: nil))
            )
        }
        return SymmetricKey(data: Data(derivedKeyBytes))
    }
}
