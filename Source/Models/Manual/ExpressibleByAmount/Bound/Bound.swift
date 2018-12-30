//
//  Bound.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-30.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public protocol Bound {
    associatedtype Magnitude: Comparable & Numeric

    init(magnitude: Magnitude) throws
    init(magnitude: Int) throws
    init(zil: Zil) throws
    init(li: Li) throws
    init(qa: Qa) throws
}
