//
//  Navigator.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

typealias Navigation<N: Navigator> = (N.Destination) -> Void

protocol AnyNavigator {
    func start()
}

protocol Navigator: AnyNavigator {
    associatedtype Destination

    func navigate(to destination: Destination)

}
