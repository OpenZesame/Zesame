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
