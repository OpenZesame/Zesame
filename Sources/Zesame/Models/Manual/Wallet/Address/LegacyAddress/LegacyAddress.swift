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

/// Checksummed legacy Ethereum style address, looking like this: `F510333720c5Dd3c3C08bC8e085e8c981ce74691` can also be
/// instantiated with a prefix of `0x`, like so: `0xF510333720c5Dd3c3C08bC8e085e8c981ce74691`
public struct LegacyAddress: AddressChecksummedConvertible, HexStringConvertible, Hashable {
    /// Checksummed hexstring representing the legacy Ethereum style address, e.g.
    /// `F510333720c5Dd3c3C08bC8e085e8c981ce74691`
    public let checksummed: HexString

    /// AddressChecksummedConvertible init.
    ///
    /// - Throws: ``Address/Error/notChecksummed`` if `hexString` is the right shape but the
    ///   case-folding doesn't match Zilliqa's checksum scheme. Use ``init(unvalidatedHex:)`` for
    ///   inputs that may not yet be checksummed.
    public init(hexString: HexStringConvertible) throws {
        guard LegacyAddress.isChecksummed(hexString: hexString) else {
            throw Address.Error.notChecksummed
        }
        checksummed = hexString.hexString
    }
}

// MARK: AddressChecksummedConvertible

public extension LegacyAddress {
    /// `LegacyAddress` is its own checksummed form.
    func toChecksummedLegacyAddress() throws -> LegacyAddress {
        self
    }
}

// MARK: - Convenience Initializers

public extension LegacyAddress {
    /// Parses a hex string, accepting an optional `0x` prefix.
    init(string: String) throws {
        try self.init(hexString: HexString(string))
    }

    /// Builds a checksummed address from a 20-byte hash. Internally re-checksums the bytes so the
    /// canonical mixed-case form is produced.
    init(compressedHash: Data) throws {
        let hexString = try HexString(compressedHash.asHex)
        let checksummed = LegacyAddress.checksummedHexstringFrom(hexString: hexString)
        try self.init(hexString: checksummed)
    }

    /// Derives the address from a public key: `address = last 20 bytes of SHA-256(compressedPubKey)`.
    init(publicKey: PublicKey) {
        do {
            // Zilliqa address = last 20 bytes of SHA256(compressedPublicKey)
            let compressed = publicKey.compressedRepresentation
            let sha256Digest = SHA256.hash(data: compressed)
            let addressBytes = Data(sha256Digest).suffix(20)
            try self.init(compressedHash: Data(addressBytes))
        } catch {
            fatalError(
                "Incorrect implementation, using `publicKey` initializer should never result in error: `\(error)`"
            )
        }
    }

    /// Convenience wrapper that pulls the public key out of a key pair.
    init(keyPair: KeyPair) {
        self.init(publicKey: keyPair.publicKey)
    }

    /// Convenience wrapper that derives the public key from a private key first.
    init(privateKey: PrivateKey) {
        self.init(publicKey: privateKey.publicKey)
    }
}

// MARK: - HexStringConvertible

public extension LegacyAddress {
    /// The canonical hex form (which is, by construction, the checksummed value).
    var hexString: HexString {
        checksummed
    }
}

// Not necessarily checksummed

public extension LegacyAddress {
    /// Validates that `hexString` has the right length to be a legacy address. Does *not* check
    /// the casing — use ``isChecksummed(hexString:)`` for that.
    static func isValidLegacyAddressButNotNecessarilyChecksummed(hexString: HexStringConvertible) throws {
        let length = hexString.length
        let expected = Address.Style.ethereum.expectedLength

        if length != expected {
            throw Address.Error.incorrectLength(
                expectedLength: expected,
                forStyle: Address.Style.ethereum,
                butGot: length
            )
        }
        // is valid
    }

    /// AddressChecksummedConvertible init.
    ///
    /// Validates only the length — re-applies Zilliqa's checksum case-folding, so any well-shaped
    /// hex (regardless of casing) round-trips into a canonical ``LegacyAddress``.
    init(unvalidatedHex hexString: HexStringConvertible) throws {
        try LegacyAddress.isValidLegacyAddressButNotNecessarilyChecksummed(hexString: hexString)
        let checksummedHexString = LegacyAddress.checksummedHexstringFrom(hexString: hexString)
        try self.init(hexString: checksummedHexString)
    }
}
