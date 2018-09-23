//
//  Scrypt.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-09-23.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import CryptoSwift
import EllipticCurveKit

public struct Scrypt {

    func deriveKey(done: @escaping (DerivedKey) -> Void)  {
        fatalError()
    }

    public struct Input: Codable, Equatable {
        /// "N", CPU/memory cost parameter, must be power of 2.
        let costParameter: Int

        /// "r", blocksize
        let blockSize: Int

        /// "p"
        let parallelizationParameter: Int

        /// "dklen"
        let lengthOfDerivedKey: Int

        let salt: Data

        enum CodingKeys: String, CodingKey {
            /// Should be lowercase "n", since that is what Zilliqa JS SDK uses
            case costParameter = "n"
            case blockSize = "r"
            case parallelizationParameter = "p"
            case lengthOfDerivedKey = "dklen"

            case salt
        }
    }

    private let passphrase: String
    private let input: Input
    
    public init(passphrase: String, input: Input) {
        self.passphrase = passphrase
        self.input = input
    }
}

public struct DerivedKey {
    let data: Data
    let from: Scrypt.Input
    fileprivate init(data: DataConvertible, from input: Scrypt.Input) {
        self.data = data.asData
        self.from = input
    }
}

extension DerivedKey: DataConvertible {}
public extension DerivedKey {
    var asData: Data {
        return data
    }
}
