//
//  MinimumGasPriceResponse.swift
//
//
//  Created by Alexander Cyon on 2021-02-22.
//

import Foundation

/// Result body of `GetMinimumGasPrice`. The node returns a Qa-denominated string which is parsed
/// into a strongly-typed ``Amount``.
public struct MinimumGasPriceResponse: Decodable {
    /// The minimum gas price the network currently accepts.
    public let amount: Amount

    /// Decodes the value from a single bare string JSON value (Qa).
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let qaString = try container.decode(String.self)
        amount = try Amount(qa: qaString)
    }
}

public extension MinimumGasPriceResponse {
    /// JSON wire keys.
    enum CodingKeys: String, CodingKey {
        case amount = "result"
    }
}
