//
//  Wallet.swift
//  ZilliqaSDKTests
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Wallet {
    public let address: Address
    public let privateKey: PrivateKey
    public let balance: Amount
    public let nonce: Nonce
}

public struct PrivateKey {}
public struct Nonce {}
