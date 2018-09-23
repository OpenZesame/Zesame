//
//  ZilliqaService+DefaultImplementations.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-09-23.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import Result
import EllipticCurveKit

public extension ZilliqaService {

    func createNewWallet(done: @escaping Done<Wallet>) {
        background {
            let newWallet = Wallet(keyPair: KeyPair(private: PrivateKey.generateNew()), network: Network.testnet)
            main {
                done(Result.success(newWallet))
            }
        }
    }

    func exportKeystoreJson(from wallet: Wallet, passphrase: String, done: @escaping Done<Keystore>) {
        // Same parameters used by Zilliqa Javascript SDK: https://github.com/Zilliqa/Zilliqa-Wallet/blob/master/src/app/zilliqa.service.ts#L142
        let salt = try! securelyGenerateBytes(count: 16).asData
        let kdfParams = Keystore.Crypto.KeyDerivationFunctionParameters(
            costParameter: 262144,
            blockSize: 1,
            parallelizationParameter: 8,
            lengthOfDerivedKey: 32,
            salt: salt.asData
        )


        try! Scrypt(passphrase: passphrase, parameters: kdfParams.toScryptParameters()).deriveKey() { derivedKey in
            let keyStore = Keystore(from: derivedKey, for: wallet)
            done(Result.success(keyStore))
        }
    }
}
