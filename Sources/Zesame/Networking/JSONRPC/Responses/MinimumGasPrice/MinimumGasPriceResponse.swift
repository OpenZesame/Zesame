//
//  MinimumGasPriceResponse.swift
//  
//
//  Created by Alexander Cyon on 2021-02-22.
//

import Foundation

public struct MinimumGasPriceResponse: Decodable {
    public let amount: ZilAmount
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let qaString = try container.decode(String.self)
        self.amount = try ZilAmount(qa: qaString)
    }
    
}


public extension MinimumGasPriceResponse {
    enum CodingKeys: String, CodingKey {
        case amount = "result"
    }
}
