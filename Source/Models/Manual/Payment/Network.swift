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

public enum Network {
    case mainnet
    case testnet(Testnet)
    public enum Testnet {
        case prod
        case staging
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
        switch self {
        case .mainnet: return 1
        case .testnet: return 62
        }
    }
}
