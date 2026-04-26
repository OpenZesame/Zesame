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

public extension Keystore {
    /// Encrypted-private-key payload of a ``Keystore``: ciphertext, AES-GCM cipher parameters,
    /// and the KDF parameters needed to re-derive the symmetric key.
    struct Crypto: Codable, Hashable {
        /// AES-GCM nonce + authentication tag, both stored in hex on the wire.
        public struct CipherParameters: Codable, Hashable {
            let nonceHex: String // 12 bytes (24 hex chars) - AES-GCM nonce
            let tagHex: String // 16 bytes (32 hex chars) - AES-GCM authentication tag

            /// Decoded nonce bytes.
            var nonce: Data {
                Data(hex: nonceHex)
            }

            /// Decoded authentication tag bytes.
            var tag: Data {
                Data(hex: tagHex)
            }

            /// Stores `nonce` and `tag` as hex.
            init(
                nonce: Data,
                tag: Data
            ) {
                nonceHex = nonce.asHex
                tagHex = tag.asHex
            }

            /// JSON wire keys.
            enum CodingKeys: String, CodingKey {
                case nonceHex = "nonce"
                case tagHex = "tag"
            }
        }

        /// Default cipher used when callers don't override.
        public static let cipherDefault = "aes-256-gcm"
        /// Expected hex length of the encrypted private key (32 bytes).
        public static let expectedLengthEncryptedPrivateKeyHex = 64 // 32 bytes
        /// Expected hex length of the AES-GCM nonce (12 bytes).
        public static let expectedLengthNonceHex = 24 // 12 bytes
        /// Expected hex length of the AES-GCM tag (16 bytes).
        public static let expectedLengthTagHex = 32 // 16 bytes
        /// Expected hex length of the KDF salt (32 bytes).
        public static let expectedLengthSaltHex = 64 // 32 bytes

        /// Symmetric cipher identifier — `"aes-256-gcm"` in this implementation.
        let cipherType: String

        /// AES-GCM nonce + authentication tag.
        let cipherParameters: CipherParameters

        /// Hex-encoded ciphertext (private key encrypted under the derived symmetric key).
        let encryptedPrivateKeyHex: String

        /// Decoded ciphertext bytes.
        var encryptedPrivateKey: Data {
            Data(hex: encryptedPrivateKeyHex)
        }

        /// Key derivation function used to stretch the password into the symmetric key.
        let kdf: KeyDerivationFunction

        /// Parameters consumed by ``kdf`` (iteration count, salt, output length).
        let keyDerivationFunctionParameters: KeyDerivationFunction.Parameters

        /// Length-validation errors produced by the designated initialiser.
        public enum Error: Swift.Error {
            /// Encrypted-private-key hex length doesn't match ``expectedLengthEncryptedPrivateKeyHex``.
            case encryptedPrivateKeyHexIncorrectLength(expectedLength: Int, butGot: Int)
            /// Salt hex length doesn't match ``expectedLengthSaltHex``.
            case saltHexIncorrectLength(expectedLength: Int, butGot: Int)
            /// Nonce hex length doesn't match ``expectedLengthNonceHex``.
            case nonceHexIncorrectLength(expectedLength: Int, butGot: Int)
            /// Tag hex length doesn't match ``expectedLengthTagHex``.
            case tagHexIncorrectLength(expectedLength: Int, butGot: Int)
        }

        /// Designated initialiser. Validates that all hex fields are the expected length so a
        /// `Crypto` value can never carry malformed wire data.
        public init(
            cipherType: String = cipherDefault,
            cipherParameters: CipherParameters,
            encryptedPrivateKeyHex: String,
            kdf: KDF,
            kdfParams: KDFParams
        ) throws {
            guard encryptedPrivateKeyHex.count == Self.expectedLengthEncryptedPrivateKeyHex else {
                throw Error.encryptedPrivateKeyHexIncorrectLength(
                    expectedLength: Self.expectedLengthEncryptedPrivateKeyHex,
                    butGot: encryptedPrivateKeyHex.count
                )
            }
            guard cipherParameters.nonceHex.count == Self.expectedLengthNonceHex else {
                throw Error.nonceHexIncorrectLength(
                    expectedLength: Self.expectedLengthNonceHex,
                    butGot: cipherParameters.nonceHex.count
                )
            }
            guard cipherParameters.tagHex.count == Self.expectedLengthTagHex else {
                throw Error.tagHexIncorrectLength(
                    expectedLength: Self.expectedLengthTagHex,
                    butGot: cipherParameters.tagHex.count
                )
            }
            guard kdfParams.saltHex.count == Self.expectedLengthSaltHex else {
                throw Error.saltHexIncorrectLength(
                    expectedLength: Self.expectedLengthSaltHex,
                    butGot: kdfParams.saltHex.count
                )
            }
            self.cipherType = cipherType
            self.cipherParameters = cipherParameters
            self.encryptedPrivateKeyHex = encryptedPrivateKeyHex
            self.kdf = kdf
            keyDerivationFunctionParameters = kdfParams
        }

        /// Decodes from JSON, routing through the validating designated initialiser so length
        /// constraints are checked even on imported keystores.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let cipherType = try container.decode(String.self, forKey: .cipherType)
            let cipherParameters = try container.decode(CipherParameters.self, forKey: .cipherParameters)
            let encryptedPrivateKeyHex = try container.decode(String.self, forKey: .encryptedPrivateKeyHex)
            let kdf = try container.decode(KDF.self, forKey: .kdf)
            let kdfParams = try container.decode(KDFParams.self, forKey: .keyDerivationFunctionParameters)
            try self.init(
                cipherType: cipherType,
                cipherParameters: cipherParameters,
                encryptedPrivateKeyHex: encryptedPrivateKeyHex,
                kdf: kdf,
                kdfParams: kdfParams
            )
        }
    }
}

public extension Keystore.Crypto {
    /// JSON wire keys for the `crypto` payload.
    enum CodingKeys: String, CodingKey {
        case cipherType = "cipher"
        case cipherParameters = "cipherparams"
        case encryptedPrivateKeyHex = "ciphertext"
        case kdf
        case keyDerivationFunctionParameters = "kdfparams"
    }
}
