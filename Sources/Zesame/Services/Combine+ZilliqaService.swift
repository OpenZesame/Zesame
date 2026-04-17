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
        callAsync { try await $0.getNetworkFromAPI() }
    }

    func getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: Bool = true)
        -> AnyPublisher<MinimumGasPriceResponse, Zesame.Error>
    {
        callAsync { try await $0.getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: alsoUpdateLocallyCachedMinimum) }
    }

    func hasNetworkReachedConsensusYetForTransactionWith(
        id: String,
        polling: Polling
    ) -> AnyPublisher<TransactionReceipt, Zesame.Error> {
        callAsync { try await $0.hasNetworkReachedConsensusYetForTransactionWith(id: id, polling: polling) }
    }

    func verifyThat(
        encryptionPassword: String,
        canDecryptKeystore keystore: Keystore
    ) -> AnyPublisher<Bool, Zesame.Error> {
        callAsync { try await $0.verifyThat(encryptionPassword: encryptionPassword, canDecryptKeystore: keystore) }
    }

    func createNewWallet(encryptionPassword: String, kdf: KDF = .default) -> AnyPublisher<Wallet, Zesame.Error> {
        callAsync { try await $0.createNewWallet(encryptionPassword: encryptionPassword, kdf: kdf) }
    }

    func restoreWallet(from restoration: KeyRestoration) -> AnyPublisher<Wallet, Zesame.Error> {
        callAsync { try await $0.restoreWallet(from: restoration) }
    }

    func exportKeystore(
        privateKey: PrivateKey,
        encryptWalletBy password: String
    ) -> AnyPublisher<Keystore, Zesame.Error> {
        callAsync { try await $0.exportKeystore(privateKey: privateKey, encryptWalletBy: password, kdf: .default) }
    }

    func getBalance(for address: LegacyAddress) -> AnyPublisher<BalanceResponse, Zesame.Error> {
        callAsync { try await $0.getBalance(for: address) }
    }

    func sendTransaction(
        for payment: Payment,
        keystore: Keystore,
        password: String,
        network: Network
    ) -> AnyPublisher<TransactionResponse, Zesame.Error> {
        callAsync {
            try await $0.sendTransaction(for: payment, keystore: keystore, password: password, network: network)
        }
    }

    func sendTransaction(
        for payment: Payment,
        signWith keyPair: KeyPair,
        network: Network
    ) -> AnyPublisher<TransactionResponse, Zesame.Error> {
        callAsync { try await $0.sendTransaction(for: payment, signWith: keyPair, network: network) }
    }

    private func callAsync<R>(_ asyncCall: @escaping (Base) async throws -> R) -> AnyPublisher<R, Zesame.Error> {
        let base = base
        let box = TaskBox()
        return Future<R, Zesame.Error> { promise in
            box.task = Task {
                do {
                    let result = try await asyncCall(base)
                    promise(.success(result))
                } catch let error as Zesame.Error {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.api(.request(error))))
                }
            }
        }
        .handleEvents(receiveCancel: { box.task?.cancel() })
        .eraseToAnyPublisher()
    }
}

final class TaskBox: @unchecked Sendable {
    var task: Task<Void, Never>?
}
