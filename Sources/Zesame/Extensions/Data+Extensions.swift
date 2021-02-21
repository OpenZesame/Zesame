//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-02-21.
//

import Foundation
import EllipticCurveKit

extension Data {
    static func fromHexString(_ hexString: String) -> Data {
        .init(hex: hexString)
    }
}
