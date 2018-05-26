//
//  Wallet.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

import EllipticCurveKeyPair

public struct Wallet {
//    public let address: Address
//    public let privateKey: EllipticCurveKeyPair.PrivateKey
//    public let balance: Amount
//    public let nonce: Nonce

    init() {}

    public enum KeyGenerationResult {
        case success(EllipticCurveKeyPair.PrivateKey)
        case error(Swift.Error)
    }

    func createPrivateKeyAndValidate(done: @escaping (KeyGenerationResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
            print("APA")
            let keys = try Wallet.createKeyPair()
            print("BANAN")
            let isValid = try Wallet.verify(privateKey: keys.private)
            guard isValid else {
                throw Error.verificationFailed
            }
            let publicKeyAttributes = try keys.public.attributes()
            print(publicKeyAttributes)
                DispatchQueue.main.async {
                    done(.success(keys.private))
                }
            } catch {
                DispatchQueue.main.async {
                    done(.error(error))
                }
            }



        }

    }

    public enum Error: Int, Swift.Error {
        case failedToCreateVerificationContext
        case verificationFailed
    }

    private static func verify(privateKey: EllipticCurveKeyPair.PrivateKey) throws -> Bool {
        print("verifying key")
        guard let verifyContext = secp256k1_context_create(UInt32(SECP256K1_FLAGS_TYPE_CONTEXT | SECP256K1_FLAGS_BIT_CONTEXT_VERIFY)) else {
            throw Error.failedToCreateVerificationContext
        }
        let attributes = try privateKey.attributes()
        print(attributes)
        fatalError()
        //        return true
        //        let verificationResult: Int32 = secp256k1_ec_seckey_verify(verifyContext, secretKey)
        //        let isValid = verificationResult == 1
        //        return isValid
    }

    private static func createKeyPair() throws -> (`public`: EllipticCurveKeyPair.PublicKey, `private`: EllipticCurveKeyPair.PrivateKey)  {
        print("Creating Config")
        let group = "org.openzesame.zilliqasdk"

//        let publicKeyAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAlways, flags: [])
//
//        let privateKeyAccessControlFlags: SecAccessControlCreateFlags = []
//
////        #if targetEnvironment(simulator)
////        privateKeyAccessControlFlags = [.userPresence]
////        #else
////        privateKeyAccessControlFlags = [.userPresence, .privateKeyUsage]
////        #endif
//        let privateKeyAccessControl = EllipticCurveKeyPair.AccessControl(protection:  kSecAttrAccessibleWhenUnlockedThisDeviceOnly, flags: privateKeyAccessControlFlags)

        let publicKeyAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAlwaysThisDeviceOnly, flags: [])

        let privateKeyAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, flags: {
            return EllipticCurveKeyPair.Device.hasSecureEnclave ? [.userPresence, .privateKeyUsage] : [.userPresence]
        }())

        let config = EllipticCurveKeyPair.Config(
            publicLabel: "publicKey",
            privateLabel: "privateKey",
            operationPrompt: "You must unlock your private key",
            publicKeyAccessControl: publicKeyAccessControl,
            privateKeyAccessControl: privateKeyAccessControl,
            publicKeyAccessGroup: group,
            privateKeyAccessGroup: group,
            token: .secureEnclaveIfAvailable)
        print("Created Config, creating manager...")
        let manager = EllipticCurveKeyPair.Manager(config: config)
        print("Created Manager, creating keys...")
        return try manager.keys()
    }
}

