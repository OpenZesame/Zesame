import Foundation
import Testing
@testable import Zesame

struct PollingTests {
    @Test func customInit() {
        let polling = Polling(.fiveTimes, backoff: .linearIncrement(of: .twoSeconds), initialDelay: .oneSecond)
        #expect(polling.count == .fiveTimes)
        #expect(polling.initialDelay == .oneSecond)
    }

    @Test func twentyTimesLinearBackoff() {
        let polling = Polling.twentyTimesLinearBackoff
        #expect(polling.count == .twentyTimes)
        #expect(polling.initialDelay == .oneSecond)
    }

    @Test func backoffLinearIncrement() {
        let backoff = Polling.Backoff.linearIncrement(of: .twoSeconds)
        let result = backoff.add(to: 3)
        #expect(result == 5)
    }

    @Test func allDelayRawValues() {
        #expect(Polling.Delay.oneSecond.rawValue == 1)
        #expect(Polling.Delay.twoSeconds.rawValue == 2)
        #expect(Polling.Delay.threeSeconds.rawValue == 3)
        #expect(Polling.Delay.fiveSeconds.rawValue == 5)
        #expect(Polling.Delay.sevenSeconds.rawValue == 7)
        #expect(Polling.Delay.tenSeconds.rawValue == 10)
        #expect(Polling.Delay.twentySeconds.rawValue == 20)
    }

    @Test func allCountRawValues() {
        #expect(Polling.Count.once.rawValue == 1)
        #expect(Polling.Count.twice.rawValue == 2)
        #expect(Polling.Count.threeTimes.rawValue == 3)
        #expect(Polling.Count.fiveTimes.rawValue == 5)
        #expect(Polling.Count.tenTimes.rawValue == 10)
        #expect(Polling.Count.twentyTimes.rawValue == 20)
    }
}
