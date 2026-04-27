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

/// The Zilliqa transaction `version` field, packing chain id (high 16 bits) and transaction
/// version (low 16 bits) into a single 32-bit value.
public struct Version {
    /// The packed 32-bit version value as it appears on the wire.
    public let value: UInt32

    /// Wraps an already-packed value.
    public init(value: UInt32) {
        self.value = value
    }

    /// Packs `network.chainId` and `transactionVersion` into the wire format.
    public init(
        network: Network,
        transactionVersion: UInt32 = 1
    ) {
        self.init(value: network.chainId << 16 + transactionVersion)
    }
}

extension Version: Equatable {}
extension Version: ExpressibleByIntegerLiteral {}
public extension Version {
    /// Allows `let v: Version = 65537` style literals.
    init(integerLiteral value: UInt32) {
        self.init(value: value)
    }
}

// MARK: - Encodable

extension Version: Encodable {
    /// Encodes as a single bare `UInt32` JSON value.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - Decodable

extension Version: Decodable {
    /// Decodes from a single bare `UInt32` JSON value.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let version = try container.decode(UInt32.self)
        self.init(value: version)
    }
}
