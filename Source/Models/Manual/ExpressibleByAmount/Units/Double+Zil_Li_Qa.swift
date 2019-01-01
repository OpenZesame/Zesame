//
//  Double+Zil_Li_Qa.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-28.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

// MARK: - Magnitude
public extension Zil.Magnitude {
    var zil: Zil {
        return Zil(value: self)
    }
}

public extension Li.Magnitude {
    var li: Li {
        return Li(value: self)
    }
}

public extension Qa.Magnitude {
    var qa: Qa {
        return Qa(value: self)
    }
}

// MARK: Integer
public extension Int {
    var zil: Zil {
        return Zil(value: self)
    }
}

public extension Int {
    var li: Li {
        return Li(value: self)
    }
}

public extension Int {
    var qa: Qa {
        return Qa(value: self)
    }
}
