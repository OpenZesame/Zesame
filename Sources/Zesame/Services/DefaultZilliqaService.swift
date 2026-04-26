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

/// Concrete ``ZilliqaService`` backed by an ``APIClient``. Also conforms to
/// ``CombineCompatible``, which exposes a `.combine` projection bridging the async API to
/// publishers.
public final class DefaultZilliqaService: ZilliqaService, CombineCompatible {
    /// The JSON-RPC client used for outbound calls.
    public let apiClient: APIClient

    /// Designated initialiser. Inject any ``APIClient`` (real or stubbed) to control the transport.
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}

public extension DefaultZilliqaService {
    /// Convenience initialiser pointing at the canonical endpoint for a named ``Network``.
    convenience init(network: Network) {
        self.init(apiClient: DefaultAPIClient(baseURL: network.baseURL))
    }

    /// Convenience initialiser for an arbitrary ``ZilliqaAPIEndpoint``.
    convenience init(endpoint: ZilliqaAPIEndpoint) {
        self.init(apiClient: DefaultAPIClient(endpoint: endpoint))
    }
}

public extension DefaultZilliqaService {
    /// Issues `GetNetworkId` against the connected node.
    func getNetworkFromAPI() async throws -> NetworkResponse {
        try await apiClient.send(method: .getNetworkId)
    }

    /// Issues `GetBalance` for the given address.
    func getBalance(for address: LegacyAddress) async throws -> BalanceResponse {
        try await apiClient.send(method: .getBalance(address))
    }

    /// Issues `GetMinimumGasPrice` and optionally updates the cached client-side minimum so
    /// subsequent ``GasPrice`` validation reflects current network conditions.
    func getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: Bool = true) async throws -> MinimumGasPriceResponse {
        let response: MinimumGasPriceResponse = try await apiClient.send(method: .getMinimumGasPrice)
        if alsoUpdateLocallyCachedMinimum {
            GasPrice.minInQa = response.amount.qa
        }
        return response
    }

    /// Issues `CreateTransaction` to broadcast `transaction`.
    func send(transaction: SignedTransaction) async throws -> TransactionResponse {
        try await apiClient.send(method: .createTransaction(transaction))
    }
}
