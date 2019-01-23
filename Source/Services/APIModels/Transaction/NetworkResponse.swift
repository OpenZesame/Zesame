//
//  NetworkResponse.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Open Zesame. All rights reserved.
//

import Foundation

public struct NetworkResponse: Decodable {
    public let network: Network

    public enum CodingKeys: String, CodingKey {
        case network = "id"
    }
}
