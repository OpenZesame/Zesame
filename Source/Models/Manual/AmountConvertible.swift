//
//  AmountConvertible.swift
//  Zesame-iOS
//
//  Created by Alexander Cyon on 2018-12-27.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public protocol AmountConvertible: Numeric, Comparable, ExpressibleByFloatLiteral, ExpressibleByStringLiteral, Codable, CustomStringConvertible, CustomDebugStringConvertible where Magnitude == Amount {

    associatedtype Amount: ExpressibleByAmount
    static var minAmount: Amount { get }
    static var maxAmount: Amount { get }
    var amount: Amount { get }
    init(amount: Amount)
    init(zil: Zil) throws
    init(li: Li) throws
    init(qa: Qa) throws
    init(zil zilString: String) throws
    init(li liString: String) throws
    init(qa qaString: String) throws
    var inZil: Zil { get }
    var inLi: Li { get }
    var inQa: Qa { get }
}

public extension AmountConvertible {
    var magnitude: Magnitude {
        return amount
    }

    init?<T>(exactly source: T) where T : BinaryInteger {
        guard let amount = Amount(exactly: source) else {
            return nil
        }
        self.init(amount: amount)
    }
}

public extension AmountConvertible {
    init(zil: Zil) throws {
        self.init(amount: try Amount(zil: zil))
    }

    init(li: Li) throws {
        self.init(amount: try Amount(li: li))
    }

    init(qa: Qa) throws {
        self.init(amount: try Amount(qa: qa))
    }
}


public extension AmountConvertible {
    init(zil zilString: String) throws {
        try self.init(zil: try Zil(zilString))
    }

    init(li liString: String) throws {
        try self.init(li: try Li(liString))
    }

    init(qa qaString: String) throws {
        try self.init(qa: try Qa(qaString))
    }
}

public extension Double {
    var zil: Zil {
        return try! Zil(self)
    }

    var li: Li {
        return try! Li(self)
    }

    var qa: Qa {
        return try! Qa(self)
    }
}

public func * <N>(lhs: Int, rhs: N) -> N where N: Numeric {
    return N(exactly: lhs)! * rhs
}
public func * <N>(lhs: N, rhs: Int) -> N where N: Numeric {
    return rhs * lhs
}

public extension AmountConvertible {

    var inZil: Zil {
        return amount.inZil
    }

    var inLi: Li {
        return amount.inLi
    }

    var inQa: Qa {
        return amount.inQa
    }

    private static func oper(_ lhs: Self, _ rhs: Self, calc: (Qa, Qa) -> Qa) -> Self {
        let result: Qa = calc(lhs.inQa, rhs.inQa)
        let amount: Amount = try! Amount(qa: result)
        return Self.init(amount: amount)
    }

    static func * (lhs: Self, rhs: Self) -> Self {
        return oper(lhs, rhs) { $0 * $1 }
    }

    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        return oper(lhs, rhs) { $0 + $1 }
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        return oper(lhs, rhs) { $0 - $1 }
    }
    
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
}

public extension AmountConvertible {

    init(string: String) throws {
        self.init(amount: try Amount.init(string))
    }

    init(floatLiteral value: Double) {
        self.init(amount: try! Amount(value))
    }

    init(stringLiteral value: String) {
        self.init(amount: try! Amount(value))
    }

    init(integerLiteral value: Int) {
        self.init(amount: try! Amount(Double(value)))
    }
}

extension AmountConvertible {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.amount < rhs.amount
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.amount == rhs.amount
    }
}

public extension AmountConvertible {
    static var powerOf: String {
        return Amount.powerOf
    }
}

public extension AmountConvertible {
    var description: String {
        return amount.description
    }
}

public extension AmountConvertible {
    var debugDescription: String {
        return amount.debugDescription
    }
}


// MARK: - Encodable
public extension AmountConvertible {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Int(amount.significand))
    }
}

// MARK: - Decodable
public extension AmountConvertible {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        do {
            let qaDebug = try Qa.init(string)
            print(qaDebug)
        } catch {
            print("failed to create Qa from: \(string)")
            print("apa")
        }
        let qa = try Qa(string)
        let amount = try Amount(qa: qa)
        self.init(amount: amount)
    }
}
