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

import Combine
import Foundation

/// The high-level façade for talking to a Zilliqa network: account/balance lookups, wallet
/// management, signing, and broadcasting transactions.
///
/// Default implementations are provided as protocol extensions, so most conformers only need to
/// supply an ``APIClient``. ``DefaultZilliqaService`` does exactly that.
public protocol ZilliqaService {
    /// The underlying JSON-RPC client used for all on-chain calls.
    var apiClient: APIClient { get }

    /// Reads the network identifier from the connected node.
    func getNetworkFromAPI() async throws -> NetworkResponse

    /// Fetches the network's current minimum gas price.
    /// - Parameter alsoUpdateLocallyCachedMinimum: When `true`, refreshes the in-process
    ///   ``GasPrice/minInQa`` cache so client-side validation matches the node.
    func getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: Bool) async throws -> MinimumGasPriceResponse

    /// Returns `true` if the password successfully decrypts the supplied keystore.
    func verifyThat(
        encryptionPassword: String,
        canDecryptKeystore: Keystore
    ) async throws -> Bool

    /// Generates a fresh private key and wraps it in a password-encrypted keystore.
    func createNewWallet(
        encryptionPassword: String,
        kdf: KDF
    ) async throws -> Wallet

    /// Materialises a ``Wallet`` from a ``KeyRestoration`` source (existing keystore or raw key).
    func restoreWallet(from restoration: KeyRestoration) async throws -> Wallet

    /// Encrypts a private key into a keystore using the chosen KDF.
    func exportKeystore(
        privateKey: PrivateKey,
        encryptWalletBy password: String,
        kdf: KDF
    ) async throws -> Keystore

    /// Reads the balance and nonce for a checksummed legacy address.
    func getBalance(for address: LegacyAddress) async throws -> BalanceResponse

    /// Broadcasts a previously signed transaction to the network.
    func send(transaction: SignedTransaction) async throws -> TransactionResponse
}

/// Combine-flavoured projection of ``ZilliqaService``. Each method returns a publisher whose
/// failure type is ``Zesame/Error`` so RxSwift/Combine pipelines can handle errors uniformly.
public protocol ZilliqaServiceReactive {
    /// Combine variant of ``ZilliqaService/getNetworkFromAPI()``.
    func getNetworkFromAPI() -> AnyPublisher<NetworkResponse, Zesame.Error>

    /// Combine variant of ``ZilliqaService/getMinimumGasPrice(alsoUpdateLocallyCachedMinimum:)``.
    func getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: Bool) -> AnyPublisher<MinimumGasPriceResponse, Zesame.Error>

    /// Combine variant of ``ZilliqaService/verifyThat(encryptionPassword:canDecryptKeystore:)``.
    func verifyThat(
        encryptionPassword: String,
        canDecryptKeystore: Keystore
    ) -> AnyPublisher<Bool, Zesame.Error>

    /// Combine variant of ``ZilliqaService/createNewWallet(encryptionPassword:kdf:)``.
    func createNewWallet(
        encryptionPassword: String,
        kdf: KDF
    ) -> AnyPublisher<Wallet, Zesame.Error>

    /// Combine variant of ``ZilliqaService/restoreWallet(from:)``.
    func restoreWallet(from restoration: KeyRestoration) -> AnyPublisher<Wallet, Zesame.Error>

    /// Combine variant of ``ZilliqaService/exportKeystore(privateKey:encryptWalletBy:kdf:)``,
    /// using the default KDF.
    func exportKeystore(
        privateKey: PrivateKey,
        encryptWalletBy password: String
    ) -> AnyPublisher<Keystore, Zesame.Error>

    /// Decrypts the keystore and yields the contained ``KeyPair``.
    func extractKeyPairFrom(
        keystore: Keystore,
        encryptedBy password: String
    ) -> AnyPublisher<KeyPair, Zesame.Error>

    /// Combine variant of ``ZilliqaService/getBalance(for:)``.
    func getBalance(for address: LegacyAddress) -> AnyPublisher<BalanceResponse, Zesame.Error>

    /// Decrypts the keystore in-line, signs, and broadcasts the payment.
    func sendTransaction(
        for payment: Payment,
        keystore: Keystore,
        password: String,
        network: Network
    ) -> AnyPublisher<TransactionResponse, Zesame.Error>

    /// Signs the payment with `keyPair` and broadcasts it.
    func sendTransaction(
        for payment: Payment,
        signWith keyPair: KeyPair,
        network: Network
    ) -> AnyPublisher<TransactionResponse, Zesame.Error>

    /// Polls the network until `id` is mined and a receipt is available, or the polling budget is
    /// exhausted.
    func hasNetworkReachedConsensusYetForTransactionWith(
        id: String,
        polling: Polling
    ) -> AnyPublisher<TransactionReceipt, Zesame.Error>
}

public extension ZilliqaServiceReactive {
    /// Convenience overload that pulls the keystore out of a ``Wallet`` first.
    func extractKeyPairFrom(
        wallet: Wallet,
        encryptedBy password: String
    ) -> AnyPublisher<KeyPair, Zesame.Error> {
        extractKeyPairFrom(keystore: wallet.keystore, encryptedBy: password)
    }

    /// Default implementation that wraps the synchronous ``Keystore/toKeypair(encryptedBy:)`` in a
    /// `Future`. Errors are normalised to ``Zesame/Error``.
    func extractKeyPairFrom(
        keystore: Keystore,
        encryptedBy password: String
    ) -> AnyPublisher<KeyPair, Zesame.Error> {
        Future { promise in
            do {
                try promise(.success(keystore.toKeypair(encryptedBy: password)))
            } catch let error as Zesame.Error {
                promise(.failure(error))
            } catch {
                // coverage:exclude-start
                // `keystore.toKeypair(encryptedBy:)` only throws `Zesame.Error` variants;
                // this generic catch is forward-compat for future error types.
                promise(.failure(.api(.request(error))))
                // coverage:exclude-end
            }
        }.eraseToAnyPublisher()
    }

    /// Convenience overload using ``Polling/twentyTimesLinearBackoff`` as the polling strategy.
    func hasNetworkReachedConsensusYetForTransactionWith(id: String) -> AnyPublisher<TransactionReceipt, Zesame.Error> {
        hasNetworkReachedConsensusYetForTransactionWith(id: id, polling: .twentyTimesLinearBackoff)
    }
}
