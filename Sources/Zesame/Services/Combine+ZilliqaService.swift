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

import Combine
import Foundation

// MARK: - CombineCompatible

public protocol CombineCompatible: AnyObject {}

public extension CombineCompatible {
    var combine: CombineWrapper<Self> {
        CombineWrapper(self)
    }
}

public struct CombineWrapper<Base> {
    public let base: Base
    fileprivate init(_ base: Base) {
        self.base = base
    }
}

// MARK: - ZilliqaServiceReactive conformance

extension CombineWrapper: ZilliqaServiceReactive where Base: ZilliqaService {}

public extension CombineWrapper where Base: ZilliqaService {
    func getNetworkFromAPI() -> AnyPublisher<NetworkResponse, Zesame.Error> {
        callBase { $0.getNetworkFromAPI(done: $1) }
    }

    func getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: Bool = true)
        -> AnyPublisher<MinimumGasPriceResponse, Zesame.Error>
    {
        callBase { $0.getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: alsoUpdateLocallyCachedMinimum, done: $1) }
    }

    func hasNetworkReachedConsensusYetForTransactionWith(
        id: String,
        polling: Polling
    ) -> AnyPublisher<TransactionReceipt, Zesame.Error> {
        callBase { $0.hasNetworkReachedConsensusYetForTransactionWith(id: id, polling: polling, done: $1) }
    }

    func verifyThat(
        encryptionPassword: String,
        canDecryptKeystore keystore: Keystore
    ) -> AnyPublisher<Bool, Zesame.Error> {
        callBase { $0.verifyThat(encryptionPassword: encryptionPassword, canDecryptKeystore: keystore, done: $1) }
    }

    func createNewWallet(encryptionPassword: String, kdf: KDF = .default) -> AnyPublisher<Wallet, Zesame.Error> {
        callBase { $0.createNewWallet(encryptionPassword: encryptionPassword, kdf: kdf, done: $1) }
    }

    func restoreWallet(from restoration: KeyRestoration) -> AnyPublisher<Wallet, Zesame.Error> {
        callBase { $0.restoreWallet(from: restoration, done: $1) }
    }

    func exportKeystore(
        privateKey: PrivateKey,
        encryptWalletBy password: String
    ) -> AnyPublisher<Keystore, Zesame.Error> {
        callBase { $0.exportKeystore(privateKey: privateKey, encryptWalletBy: password, done: $1) }
    }

    func getBalance(for address: LegacyAddress) -> AnyPublisher<BalanceResponse, Zesame.Error> {
        callBase { $0.getBalance(for: address, done: $1) }
    }

    func sendTransaction(
        for payment: Payment,
        keystore: Keystore,
        password: String,
        network: Network
    ) -> AnyPublisher<TransactionResponse, Zesame.Error> {
        callBase { $0.sendTransaction(for: payment, keystore: keystore, password: password, network: network, done: $1)
        }
    }

    func sendTransaction(
        for payment: Payment,
        signWith keyPair: KeyPair,
        network: Network
    ) -> AnyPublisher<TransactionResponse, Zesame.Error> {
        callBase { $0.sendTransaction(for: payment, signWith: keyPair, network: network, done: $1) }
    }

    private func callBase<R>(call: @escaping (Base, @escaping Done<R>) -> Void) -> AnyPublisher<R, Zesame.Error> {
        Future { [weak base] promise in
            guard let base else { return }
            call(base, promise)
        }.eraseToAnyPublisher()
    }
}
