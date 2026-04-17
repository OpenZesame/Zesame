//
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
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
    struct Crypto: Codable, Hashable {
        public struct CipherParameters: Codable, Hashable {
            let nonceHex: String // 12 bytes (24 hex chars) - AES-GCM nonce
            let tagHex: String // 16 bytes (32 hex chars) - AES-GCM authentication tag

            var nonce: Data {
                Data(hex: nonceHex)
            }

            var tag: Data {
                Data(hex: tagHex)
            }

            init(nonce: Data, tag: Data) {
                nonceHex = nonce.asHex
                tagHex = tag.asHex
            }

            enum CodingKeys: String, CodingKey {
                case nonceHex = "nonce"
                case tagHex = "tag"
            }
        }

        public static let cipherDefault = "aes-256-gcm"
        public static let expectedLengthEncryptedPrivateKeyHex = 64 // 32 bytes
        public static let expectedLengthNonceHex = 24 // 12 bytes
        public static let expectedLengthTagHex = 32 // 16 bytes
        public static let expectedLengthSaltHex = 64 // 32 bytes

        let cipherType: String
        let cipherParameters: CipherParameters
        let encryptedPrivateKeyHex: String
        var encryptedPrivateKey: Data {
            Data(hex: encryptedPrivateKeyHex)
        }

        let kdf: KeyDerivationFunction
        let keyDerivationFunctionParameters: KeyDerivationFunction.Parameters

        public enum Error: Swift.Error {
            case encryptedPrivateKeyHexIncorrectLength(expectedLength: Int, butGot: Int)
            case saltHexIncorrectLength(expectedLength: Int, butGot: Int)
            case nonceHexIncorrectLength(expectedLength: Int, butGot: Int)
            case tagHexIncorrectLength(expectedLength: Int, butGot: Int)
        }

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
    enum CodingKeys: String, CodingKey {
        case cipherType = "cipher"
        case cipherParameters = "cipherparams"
        case encryptedPrivateKeyHex = "ciphertext"
        case kdf
        case keyDerivationFunctionParameters = "kdfparams"
    }
}
