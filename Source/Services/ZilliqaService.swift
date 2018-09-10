//
//  ZilliqaService.swift
//  ZilliqaSDK iOS
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import JSONRPCKit
import Result
import APIKit
import RxCocoa
import RxSwift

public protocol ZilliqaService {
    var wallet: Wallet { get }
    func getBalalance(_ handler: @escaping (Result<BalanceResponse, Error>) -> Void)
}
