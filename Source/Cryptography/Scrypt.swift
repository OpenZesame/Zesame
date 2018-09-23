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
    private let passphrase: String
    private let parameters: Parameters

    init(passphrase: String, parameters: Parameters) {
        self.passphrase = passphrase
        self.parameters = parameters
    }
}

public extension Scrypt {
    public struct Parameters {
        /// "N", CPU/memory cost parameter, must be power of 2.
        let costParameter: Int

        /// "r", blocksize
        let blockSize: Int

        /// "p"
        let parallelizationParameter: Int

        /// "dklen"
        let lengthOfDerivedKey: Int

        let salt: Data
    }
}

public extension Scrypt {
    func deriveKey(done: @escaping (DerivedKey) -> Void)  {
        fatalError()
    }
}

public struct DerivedKey {
    public let data: Data
    public let parametersUsed: Scrypt.Parameters
    fileprivate init(data: DataConvertible, parametersUsed: Scrypt.Parameters) {
        self.data = data.asData
        self.parametersUsed = parametersUsed
    }
}

extension DerivedKey: DataConvertible {}
public extension DerivedKey {
    var asData: Data {
        return data
    }
}
