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

/// A minimum container of a valid Bech32 address containing the prefix, delimiter, data (relevant information) and
/// checksum
public struct Bech32Address:
    AddressChecksummedConvertible,
    StringConvertible,
    Hashable,
    ExpressibleByStringLiteral
{
    /// The human-readable prefix (`zil` for mainnet, `tzil` for testnet).
    public let humanReadablePrefix: String
    /// The 5-bit-grouped address bytes plus the 6-symbol checksum.
    public let dataPart: DataPart

    /// Memberwise initialiser. Internal — public construction goes through the throwing
    /// initialisers that compute the checksum.
    init(
        prefix: String,
        dataPart: DataPart
    ) {
        humanReadablePrefix = prefix
        self.dataPart = dataPart
    }

    /// Convenience that derives the prefix from `network`.
    init(
        network: Network,
        dataPart: DataPart
    ) {
        self.init(prefix: network.bech32Prefix, dataPart: dataPart)
    }
}

public extension Bech32Address {
    /// Failures specific to constructing a ``Bech32Address`` from raw bytes.
    enum Error: Swift.Error, Equatable {
        /// The supplied address bytes weren't 20 bytes long.
        case incorrectDataLength(expectedByteCountOf: Int, butGot: Int)
    }
}

public extension Bech32Address {
    /// Converts the bech32 form to a checksummed legacy hex address.
    func toChecksummedLegacyAddress() throws -> LegacyAddress {
        guard let relevantInfoPart = dataPart.excludingChecksum else {
            throw Address.Error.bech32DataEmpty
        }

        let expectedLength = Address.Style.bech32.expectedLength
        let length = relevantInfoPart.asString.count
        guard length == expectedLength else {
            throw Address.Error.incorrectLength(
                expectedLength: expectedLength,
                forStyle: Address.Style.bech32,
                butGot: length
            )
        }

        let addressAsData = try Bech32.convertbits(
            data: Array(relevantInfoPart.data),
            fromBits: 5,
            toBits: 8,
            pad: false
        )
        let hexString = try HexString(addressAsData.asHex)
        let ethStyleNotNecessarilyChecksummed = try LegacyAddress(unvalidatedHex: hexString)
        return try ethStyleNotNecessarilyChecksummed.toChecksummedLegacyAddress()
    }
}

public extension Bech32Address {
    /// Builds a Bech32 address from a 20-byte payload by computing the 5-bit-grouped form and
    /// the 6-symbol checksum for `prefix`.
    init(
        prefix: String,
        unchecksummedData: Data
    ) throws {
        let expectedByteCount = 20
        let byteCount = unchecksummedData.count
        guard byteCount == expectedByteCount else {
            throw Error.incorrectDataLength(expectedByteCountOf: expectedByteCount, butGot: byteCount)
        }
        let value = try Bech32.convertbits(data: Array(unchecksummedData), fromBits: 8, toBits: 5, pad: false).asData
        let checksum = Bech32.createChecksum(humanReadablePart: prefix, values: value)

        self.init(
            prefix: prefix,
            dataPart:
            DataPart(
                dataExcludingChecksum: value,
                checksum: checksum
            )
        )
    }

    /// Convenience that picks the prefix from `network`.
    init(
        network: Network,
        unchecksummedData: Data
    ) throws {
        try self.init(prefix: network.bech32Prefix, unchecksummedData: unchecksummedData)
    }

    /// Builds a Bech32 address from a legacy hex address.
    init(
        ethStyleAddress address: LegacyAddress,
        network: Network = .mainnet
    ) throws {
        try self.init(
            network: network,
            unchecksummedData: address.asData
        )
    }

    /// Builds a Bech32 address from a hex address string. Validates checksumming first.
    init(
        ethStyleAddress address: String,
        network: Network = .mainnet
    ) throws {
        let checksummedAddress = try LegacyAddress(string: address)
        try self.init(ethStyleAddress: checksummedAddress, network: network)
    }

    /// Parses a full bech32 string (e.g. `"zil1…"`).
    init(bech32String: String) throws {
        self = try Bech32.decode(bech32String)
    }
}

public extension Bech32Address {
    /// Allows ``Bech32Address`` to be written as a string literal. Traps on invalid input.
    init(stringLiteral bech32String: String) {
        do {
            try self.init(bech32String: bech32String)
        } catch {
            fatalError("Not a valid Bech32 address")
        }
    }
}

public extension Bech32Address {
    /// The data portion of a Bech32 address — the address bytes plus their checksum.
    struct DataPart: Hashable, CustomStringConvertible {
        /// Address bytes (5-bit-grouped). `nil` when the address is checksum-only.
        public let excludingChecksum: Bech32Data?
        /// 6-symbol Bech32 checksum.
        public let checksum: Bech32Data

        /// Memberwise initialiser.
        public init(
            excludingChecksum: Bech32Data?,
            checksum: Bech32Data
        ) {
            self.excludingChecksum = excludingChecksum
            self.checksum = checksum
        }
    }
}

public extension Bech32Address.DataPart {
    /// Convenience wrapper that lifts raw `Data` into the strongly-typed ``Bech32Data`` form.
    init(
        dataExcludingChecksum: Data,
        checksum: Data
    ) {
        self.init(
            excludingChecksum: Bech32Data(dataExcludingChecksum),
            checksum: Bech32Data(checksum)
        )
    }

    /// Address bytes concatenated with the checksum (the canonical wire form of the data part).
    var includingChecksum: Bech32Data {
        guard let excludingChecksum else {
            return checksum
        }
        return Bech32Data(excludingChecksum.data + checksum.data)
    }

    /// Renders the data part as its Bech32 string form (with checksum).
    var description: String {
        includingChecksum.description
    }
}

public extension Bech32Address.DataPart {
    /// Strongly-typed wrapper around the 5-bit-grouped Bech32 byte representation.
    struct Bech32Data: Hashable, CustomStringConvertible {
        /// Raw 5-bit-grouped bytes.
        public let data: Data

        /// Wraps the bytes.
        public init(_ data: Data) {
            self.data = data
        }
    }
}

public extension Bech32Address.DataPart.Bech32Data {
    /// Renders the bytes via ``Bech32/dataToString(data:)``.
    var asString: String {
        Bech32.dataToString(data: data)
    }

    /// `description` is identical to ``asString``.
    var description: String {
        asString
    }
}

// MARK: - StringConvertible

public extension Bech32Address {
    /// Full canonical Bech32 string: `<hrp>1<data><checksum>`.
    var asString: String {
        [
            humanReadablePrefix,
            Bech32.checksumMarker,
            dataPart.description,
        ].joined()
    }
}

extension Network {
    /// Resolves a network from a Bech32 prefix (`zil` → mainnet, `tzil` → testnet).
    init(bech32Prefix: String) throws {
        let bech32Prefix = bech32Prefix.lowercased()
        if bech32Prefix == Network.testnet.bech32Prefix {
            self = .testnet
        } else if bech32Prefix == Network.mainnet.bech32Prefix {
            self = .mainnet
        } else {
            throw Bech32Error.unrecognizedBech32Prefix(bech32Prefix)
        }
    }
}

public extension Network {
    /// Failures for ``Network/init(bech32Prefix:)``.
    enum Bech32Error: Swift.Error {
        /// The given prefix doesn't match any known Zilliqa network.
        case unrecognizedBech32Prefix(String)
    }

    /// Bech32 prefix associated with this network (`zil` for mainnet, `tzil` for testnet).
    var bech32Prefix: String {
        switch self {
        case .testnet:
            "tzil"
        case .mainnet:
            "zil"
        }
    }
}
