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
import Zesame

/// ⚠️ THIS IS TERRIBLE! DONT USE THIS! This is HIGHLY unsafe and secure. It is temporary and will be removed soon.
struct Unsafe︕！Cache {
    enum Key: String {
        case wallet
    }

    static func stringForKey(_ key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }

    static func dataForKey(_ key: Key) -> Data? {
        return UserDefaults.standard.data(forKey: key.rawValue)
    }

    static var wallet: Wallet? {
        guard
            let walletData = Unsafe︕！Cache.dataForKey(.wallet),
        let wallet = try? JSONDecoder().decode(Wallet.self, from: walletData)
        else { return nil }
        return wallet
    }

    static var isWalletConfigured: Bool {
        return wallet != nil
    }

    static func unsafe︕！Store(value: Any, forKey key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func unsafe︕！Store(wallet: Wallet) {
        let data = try! JSONEncoder().encode(wallet)
        unsafe︕！Store(value: data, forKey: .wallet)
    }

    static func deleteWallet() {
        deleteValueFor(key: .wallet)
    }

    static func deleteValueFor(key: Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
