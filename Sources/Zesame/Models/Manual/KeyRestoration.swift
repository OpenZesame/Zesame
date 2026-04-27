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

/// The starting point for restoring a wallet — either a raw private key (which will be encrypted
/// into a new keystore) or an existing keystore (with the password to decrypt it).
public enum KeyRestoration {
    /// A raw private key to be wrapped in a fresh keystore using `encryptBy`/`kdf`.
    case privateKey(PrivateKey, encryptBy: String, kdf: KDF)
    /// An existing keystore plus the password that unlocks it.
    case keystore(Keystore, password: String)
}

public extension KeyRestoration {
    /// Builds a ``KeyRestoration/privateKey(_:encryptBy:kdf:)`` from a hex-encoded private key.
    ///
    /// - Throws:
    ///   - ``Zesame/Error/walletImport(_:)`` (`.badPrivateKeyHex`) if the string is not valid
    ///     hexadecimal.
    ///   - ``Zesame/Error/walletImport(_:)`` (`.invalidPrivateKey`) if the bytes are valid hex
    ///     but rejected by the secp256k1 layer; the underlying K1 error is preserved.
    init(
        privateKeyHexString: String,
        encryptBy newPassword: String,
        kdf: KDF = .default
    ) throws {
        guard let privateKeyData = Data(validatingHex: privateKeyHexString) else {
            throw Error.walletImport(.badPrivateKeyHex)
        }
        let privateKey: PrivateKey
        do {
            privateKey = try PrivateKey(rawRepresentation: privateKeyData)
        } catch {
            throw Error.walletImport(.invalidPrivateKey(error))
        }
        self = .privateKey(privateKey, encryptBy: newPassword, kdf: kdf)
    }

    /// Builds a ``KeyRestoration/keystore(_:password:)`` from raw keystore JSON.
    ///
    /// - Throws:
    ///   - ``Zesame/Error/walletImport(_:)`` (`.jsonDecoding`) if `JSONDecoder` rejects the
    ///     payload as malformed.
    ///   - ``Zesame/Error/walletImport(_:)`` (`.keystoreError`) for any other decoder/keystore
    ///     failure (e.g. a `Foundation` non-`DecodingError` thrown on Linux).
    init(
        keyStoreJSON: Data,
        encryptedBy password: String
    ) throws {
        do {
            let keystore = try JSONDecoder().decode(Keystore.self, from: keyStoreJSON)
            self = .keystore(keystore, password: password)
        } catch let error as Swift.DecodingError {
            throw Error.walletImport(.jsonDecoding(error))
        } catch let error as Zesame.Error {
            // coverage:exclude-start
            // The keystore decoder doesn't surface `Zesame.Error` directly today; this branch is
            // forward-compat in case a future decoder rethrows one verbatim.
            throw error
            // coverage:exclude-end
        } catch {
            throw Error.walletImport(.keystoreError(error))
        }
    }

    /// Convenience overload that re-encodes a JSON string into bytes first.
    ///
    /// - Throws: ``Zesame/Error/walletImport(_:)`` (`.jsonStringDecoding`) if the string is not
    ///   representable in `encoding`.
    init(
        keyStoreJSONString: String,
        encodedBy encoding: String.Encoding = .utf8,
        encryptedBy password: String
    ) throws {
        guard let json = keyStoreJSONString.data(using: encoding) else {
            throw Error.walletImport(.jsonStringDecoding)
        }

        try self.init(keyStoreJSON: json, encryptedBy: password)
    }
}
