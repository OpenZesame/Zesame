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

import EllipticCurveKit

public final class DefaultZilliqaService: ZilliqaService {

    public let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}

public extension DefaultZilliqaService {
    convenience init(network: Network) {
        let apiClient = DefaultAPIClient(baseURL: network.baseURL)
        self.init(apiClient: apiClient)
    }
    
    convenience init(endpoint: ZilliqaAPIEndpoint) {
        self.init(apiClient: DefaultAPIClient(endpoint: endpoint))
    }
}

public extension DefaultZilliqaService {

    func getNetworkFromAPI() async throws -> NetworkResponse {
        try await apiClient.send(method: .getNetworkId)
    }

    func getBalance(for address: LegacyAddress) async throws -> BalanceResponse {
        try await apiClient.send(method: .getBalance(address))
    }

    func getMinimumGasPrice(
        alsoUpdateLocallyCachedMinimum: Bool = true
    ) async throws -> MinimumGasPriceResponse {
        let newMinimumPrice: MinimumGasPriceResponse = try await apiClient.send(method: .getMinimumGasPrice)
        if alsoUpdateLocallyCachedMinimum {
            GasPrice.minInQa = newMinimumPrice.amount.qa
        }
        return newMinimumPrice
    }

    func send(transaction: SignedTransaction) async throws -> TransactionResponse {
        try await apiClient.send(method: .createTransaction(transaction))
    }
}
