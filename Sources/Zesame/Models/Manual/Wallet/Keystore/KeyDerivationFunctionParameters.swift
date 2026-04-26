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

/// Convenience alias for ``KDF/Parameters``.
public typealias KDFParams = KDF.Parameters

public extension KDF {
    /// PBKDF2 parameters — iteration count, output length, and salt — embedded in keystores so
    /// they can be re-derived at decrypt time.
    struct Parameters: Codable, Hashable {
        /// OWASP 2023 recommendation for PBKDF2-SHA512
        public static let defaultIterations = 600_000
        /// Default derived-key length in bytes (32 bytes = 256-bit AES key).
        public static let defaultDerivedKeyLength = 32
        /// Always HMAC-SHA512; encoded in JSON for interoperability
        static let prf = "hmac-sha512"

        /// PBKDF2 iteration count ("c" in JSON)
        public let iterations: Int
        /// Derived key length in bytes ("dklen" in JSON)
        public let derivedKeyLength: Int
        /// Hex-encoded salt.
        public let saltHex: String

        /// Decoded salt bytes.
        public var salt: Data {
            Data(hex: saltHex)
        }

        /// Designated initialiser. If `saltHex` is `nil`, a fresh 32-byte salt is generated via
        /// the platform CSPRNG.
        public init(
            iterations: Int = Self.defaultIterations,
            derivedKeyLength: Int = Self.defaultDerivedKeyLength,
            saltHex: String? = nil
        ) throws {
            self.iterations = iterations
            self.derivedKeyLength = derivedKeyLength
            self.saltHex = try saltHex ?? securelyGenerateBytes(count: 32).asHex
        }

        /// Decodes from JSON. The `prf` field on the wire is informational only — this
        /// implementation always uses HMAC-SHA512.
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            iterations = try c.decode(Int.self, forKey: .iterations)
            derivedKeyLength = try c.decode(Int.self, forKey: .derivedKeyLength)
            saltHex = try c.decode(String.self, forKey: .saltHex)
        }

        /// Encodes to JSON, including the constant `prf` field for cross-implementation
        /// interoperability.
        public func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(Self.prf, forKey: .prf)
            try c.encode(iterations, forKey: .iterations)
            try c.encode(derivedKeyLength, forKey: .derivedKeyLength)
            try c.encode(saltHex, forKey: .saltHex)
        }

        /// JSON wire keys.
        enum CodingKeys: String, CodingKey {
            case prf
            case iterations = "c"
            case derivedKeyLength = "dklen"
            case saltHex = "salt"
        }
    }
}

public extension KDF.Parameters {
    // swiftlint:disable:next force_try
    /// Default parameters: OWASP iteration count and a freshly-generated 32-byte salt.
    static let `default`: Self = try! .init()
}
