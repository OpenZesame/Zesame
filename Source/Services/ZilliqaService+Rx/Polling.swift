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

    public init(_ count: Count, backoff: Backoff, initialDelay: Delay) {
        self.count = count
        self.backoff = backoff
        self.initialDelay = initialDelay
    }
}

public extension Polling {
    static var twentyTimesLinearBackoff: Polling {
        return Polling(.twentyTimes,
                       backoff: .linearIncrement(of: .twoSeconds),
                       initialDelay: .oneSecond
        )
    }

    public enum Backoff {
        case linearIncrement(of: Delay)
    }

    public enum Delay: Int {
        case oneSecond = 1
        case twoSeconds = 2
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
        case twentyTimes = 20
    }
}

public extension ZilliqaService {
    func hasNetworkReachedConsensusYetForTransactionWith(id: String, polling: Polling, done: @escaping Done<TransactionReceipt>) {
        let start = DispatchTime.now()

        func fetch(retriesLeft: Int, waitUntilCall delayInSeconds: Int) {
            print("\nfetch - retriesLeft: \(retriesLeft), delayInSeconds: \(delayInSeconds)")
            let delay = DispatchTimeInterval.seconds(delayInSeconds)

            func printElapsedTime() {
                let end = DispatchTime.now()
                let timeInterval = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000 // Technically could overflow for long running tests
                print("took: \(timeInterval)s, using: \(polling.count.rawValue - retriesLeft) polls")
            }

            background(delay: delay) { [unowned self] in
                self.getStatusOfTransaction(id: id) {
                    if case .success(let status) = $0, case let receipt = status.receipt, receipt.isSent {
                        printElapsedTime()
                        return done(
                            .success(
                                TransactionReceipt(id: id, totalGasCost: receipt.totalGasCost)
                            )
                        )
                    }

                    // Stop recursion with failure when retry count reached zero
                    guard retriesLeft > 0 else {
                        printElapsedTime()
                        return done(.failure(Error.api(.timeout)))
                    }

                    // Recursivly call self
                    let increasedDelay: Int
                    switch polling.backoff {
                    case .linearIncrement(let delayIncrement):
                        increasedDelay = delayInSeconds + delayIncrement.rawValue
                    }

                    fetch(retriesLeft: retriesLeft - 1, waitUntilCall: increasedDelay)
                }
            }
        }

        // initial
        fetch(retriesLeft: polling.count.rawValue, waitUntilCall: polling.initialDelay.rawValue)
    }
}

private extension ZilliqaService {
    func getStatusOfTransaction(id: String, done: @escaping Done<StatusOfTransactionResponse>) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        print("\(dateFormatter.string(from: Date())) - Checking status of tx: \(id)")
        return apiClient.send(request: StatusOfTransactionRequest(transactionId: id), done: done)
    }
}
