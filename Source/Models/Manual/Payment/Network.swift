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

/// ⚠️ THE VALUES ARE NOT CONFIRMED
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
    var baseURL: URL {
        let baseUrlString: String
        switch self {
        case .mainnet: baseUrlString = "https://api.zilliqa.com"
        case .testnet(let testnet):
            switch testnet {
            case .prod:
                // Before mainnet launch testnet prod is "borrowing" that url.
                return Network.mainnet.baseURL
            case .staging: baseUrlString = "https://staging-api.aws.zilliqa.com"
            }
        }
        return URL(string: baseUrlString)!
    }
    
    var chainId: UInt32 {
        print("⚠️ Using uncofirmed chain id. Verify that this is the correct chain id before launch.")
        return rawValue
    }

    func compressedHashForAddressFromPublicKey(_ publicKey: PublicKey) -> Data {
        // Actually using Bitcoin `mainnet` settings for address formatting. As of not not related to `Zesame.Network`
        let system = EllipticCurveKit.Zilliqa(EllipticCurveKit.Zilliqa.Network.mainnet)
        return system.compressedHash(from: publicKey)
    }
}
