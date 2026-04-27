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

/// Identifies a Zilliqa network. The raw value is the network's chain id.
///
/// seemore: https://apidocs.zilliqa.com/#getnetworkid
public enum Network: UInt32, Decodable {
    /// The production network.
    case mainnet = 1
    /// Public test network used for development.
    case testnet = 333
}

extension Network {
    /// Canonical JSON-RPC endpoint URL for this network.
    var baseURL: URL {
        switch self {
        case .mainnet: ZilliqaAPIEndpoint.mainnet.baseURL
        case .testnet: ZilliqaAPIEndpoint.testnet.baseURL
        }
    }
}

// MARK: - Decodable

public extension Network {
    /// Decodes from the string-encoded chain id returned by `GetNetworkId`. Throws a
    /// `dataCorrupted` error if the string isn't an integer or isn't a known network.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let chainIdAsString = try container.decode(String.self)
        guard let chainId = UInt32(chainIdAsString) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to parse chain id string (`\(chainIdAsString)`) as integer"
            )
        }
        guard let network = Network(rawValue: chainId) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Received new chain id: \(chainId), you need to add this to the enum `Network`"
            )
        }
        self = network
    }
}

public extension Network {
    /// Default network used when a caller doesn't specify (mainnet).
    static var `default`: Network {
        .mainnet
    }
}

public extension Network {
    /// Numeric chain id, equal to the enum's raw value.
    var chainId: UInt32 {
        rawValue
    }
}
