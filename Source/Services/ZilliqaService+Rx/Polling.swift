//
//  Polling.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-12-11.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

public struct Polling {
    public let count: Count
    public let backoff: Backoff
    public let initialDelay: Delay

    public init(
        _ count: Count = .tenTimes,
        backoff: Backoff = .linearIncrement(of: .oneSecond),
        initialDelay: Delay = .fiveSeconds) {
        self.count = count
        self.backoff = backoff
        self.initialDelay = initialDelay
    }
}

public extension Polling {
    static var tenTimesLinearBackoff: Polling {
        return Polling(.tenTimes,
                       backoff: .linearIncrement(of: .oneSecond),
                       initialDelay: .fiveSeconds
        )
    }

    public enum Backoff {
        case linearIncrement(of: Delay)
    }

    public enum Delay: TimeInterval {
        case oneSecond
        case threeSeconds = 3
        case fiveSeconds = 5
        case sevenSeconds = 7
        case tenSeconds = 10
    }

    public enum Count: Int {
        case once = 1
        case twice = 2
        case threeTimes = 3
        case fiveTimes = 5
        case tenTimes = 10
    }
}

extension ZilliqaService {
    func statusOfTransaction(id: String, polling: Polling = .tenTimesLinearBackoff, done: @escaping Done<StatusOfTransactionResponse>) {

        let startDelay = DispatchTimeInterval.seconds(Int(polling.initialDelay.rawValue))

        background(delay: startDelay) { [unowned self] in
            return self.getStatusOfTransaction(id: id, done: done)
        }
    }

    private func getStatusOfTransaction(id: String, done: @escaping Done<StatusOfTransactionResponse>) {
        return apiClient.send(request: StatusOfTransactionRequest(transactionId: id), done: done)
    }
}
