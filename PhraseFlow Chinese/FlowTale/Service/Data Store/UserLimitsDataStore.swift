//
//  UserLimitsDataStore.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

class UserLimitsDataStore: UserLimitsDataStoreProtocol {
    private let keychain = KeychainManager.shared
    private let kDailyCharacterUsageKey = "dailyCharacterUsageData"
    private let kFreeUserCharacterTotalKey = "freeUserCharacterCount"

    func trackSSMLCharacterUsage(characterCount: Int, subscription: SubscriptionLevel?) throws {
        guard let subscription = subscription else {
            try trackFreeUserCharacterUsage(characterCount)
            return
        }

        try trackSubscribedUserCharacterUsage(characterCount, level: subscription)
    }

    private func trackFreeUserCharacterUsage(_ characterCount: Int) throws {
        let currentTotal = loadFreeUserCharacterCount()
        #if DEBUG
            let maxFree = 999_999_999_999_999_999
        #else
            let maxFree = 4000
        #endif

        if currentTotal + characterCount > maxFree {
            throw FlowTaleDataStoreError.freeUserCharacterLimitReached
        }

        let newCount = currentTotal + characterCount
        try keychain.setData(Data("\(newCount)".utf8), forKey: kFreeUserCharacterTotalKey)
    }

    private func trackSubscribedUserCharacterUsage(_ characterCount: Int, level: SubscriptionLevel) throws {
        var usageRecords = try loadDailyCharacterUsage()
        let now = Date()
        let cutoff = now.addingTimeInterval(-24 * 60 * 60)

        usageRecords = usageRecords.filter { $0.timestamp > cutoff }

        let totalUsage = usageRecords.reduce(0) { $0 + $1.characterCount }

        let limit = level.ssmlCharacterLimitPerDay
        if totalUsage + characterCount > limit {
            if let earliest = usageRecords.map({ $0.timestamp }).min() {
                let nextAvailableTimeString = timeRemainingStringUntilNextAvailable(earliestTimeStamp: earliest)
                throw FlowTaleDataStoreError.characterLimitReached(timeUntilNextAvailable: nextAvailableTimeString)
            } else {
                throw FlowTaleDataStoreError.characterLimitReached(timeUntilNextAvailable: "24 hours")
            }
        }

        usageRecords.append(CharacterUsageRecord(timestamp: now, characterCount: characterCount))
        try saveDailyCharacterUsage(usageRecords)
    }

    private func timeRemainingStringUntilNextAvailable(earliestTimeStamp: Date) -> String {
        let now = Date()
        let nextAvailable = earliestTimeStamp.addingTimeInterval(24 * 60 * 60)

        let interval = nextAvailable.timeIntervalSince(now)
        guard interval > 0 else {
            return "Now"
        }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.dropAll]
        formatter.calendar?.locale = .current

        if let formatted = formatter.string(from: interval) {
            return formatted
        } else {
            return "24 hours"
        }
    }

    private func loadDailyCharacterUsage() throws -> [CharacterUsageRecord] {
        guard let data = keychain.getData(forKey: kDailyCharacterUsageKey) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode([CharacterUsageRecord].self, from: data)
        } catch {
            return []
        }
    }

    private func saveDailyCharacterUsage(_ usage: [CharacterUsageRecord]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(usage)
        try keychain.setData(data, forKey: kDailyCharacterUsageKey)
    }

    private func loadFreeUserCharacterCount() -> Int {
        guard let data = keychain.getData(forKey: kFreeUserCharacterTotalKey),
              let stringVal = String(data: data, encoding: .utf8),
              let intVal = Int(stringVal) else {
            return 0
        }
        return intVal
    }
}
