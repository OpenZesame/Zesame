//
//  ExpressibleByAmount+Codable.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2018-12-27.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

// MARK: - Encodable
public extension ExpressibleByAmount {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Int(magnitude))
    }
}

// MARK: - Decodable
public extension ExpressibleByAmount where Self: Bound {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let zil = try Zil(qa: string)
        try self.init(zil: zil)
    }
}

public extension ExpressibleByAmount where Self: Unbound {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let zil = try Zil(qa: string)
        self.init(zil: zil)
    }
}
