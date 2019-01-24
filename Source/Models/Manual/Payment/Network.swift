//
// Copyright 2019 Open Zesame
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under thexc License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import EllipticCurveKit

public enum Network: UInt32, Decodable {
    case mainnet = 1
    case testnet = 2
}

// MARK: - Encodable
public extension Network {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(chainId)
    }
}

// MARK: - Decodable
public extension Network {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let chainId = try container.decode(UInt32.self)
        guard let network = Network(rawValue: chainId) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Received new chain id: \(chainId), you need to add this to the enum `Network`")
        }
        self = network
    }
}

public extension Network {
    static var `default`: Network {
        return .mainnet
    }
}

public extension Network {
    var chainId: UInt32 {
        return rawValue
    }
}
