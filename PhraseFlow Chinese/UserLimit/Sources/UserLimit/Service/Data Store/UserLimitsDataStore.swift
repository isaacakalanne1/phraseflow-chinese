//
//  UserLimitsDataStore.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import DataStorage
import Foundation
import Localization

public enum UserLimitsDataStoreError: Error {
    case freeUserCharacterLimitReached
    case characterLimitReached(timeUntilNextAvailable: String)
}

public class UserLimitsDataStore: UserLimitsDataStoreProtocol {
    private let keychain = KeychainManager.shared
    private let dailyUsageKey = "dailyCharacterUsageData"
    private let freeCountKey = "freeUserCharacterCount"
    
    private var freeUserLimit: Int {
        SubscriptionLevel.free.ssmlCharacterLimitPerDay
    }
    
    public init() {
        
    }
    
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    public func trackSSMLCharacterUsage(characterCount: Int,
                                        characterLimitPerDay: Int?) throws {
        if let characterLimitPerDay {
            try trackSubscribedUser(characterCount, characterLimitPerDay: characterLimitPerDay)
        } else {
            try trackFreeUser(characterCount)
        }
    }

    private func trackFreeUser(_ count: Int) throws {
        guard freeUserCount + count <= freeUserLimit else {
            throw UserLimitsDataStoreError.freeUserCharacterLimitReached
        }
        
        try keychain.setData(Data("\(freeUserCount + count)".utf8), forKey: freeCountKey)
    }

    private func trackSubscribedUser(_ count: Int, characterLimitPerDay: Int) throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(-86400)
        var records = dailyUsage.filter { $0.timestamp > cutoff }
        
        let totalUsage = records.reduce(0) { $0 + $1.characterCount }
        
        guard totalUsage + count <= characterLimitPerDay else {
            let timeString = records.compactMap(\.timestamp).min()
                .map(timeRemaining) ?? "24 hours"
            throw UserLimitsDataStoreError.characterLimitReached(timeUntilNextAvailable: timeString)
        }
        
        records.append(CharacterUsageRecord(timestamp: now, characterCount: count))
        try saveDailyUsage(records)
    }

    private func timeRemaining(from earliest: Date) -> String {
        let interval = earliest.addingTimeInterval(86400).timeIntervalSince(Date())
        guard interval > 0 else { return "Now" }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.dropAll]
        formatter.calendar?.locale = .current
        
        return formatter.string(from: interval) ?? "24 hours"
    }

    private var dailyUsage: [CharacterUsageRecord] {
        guard let data = keychain.getData(forKey: dailyUsageKey) else { return [] }
        return (try? jsonDecoder.decode([CharacterUsageRecord].self, from: data)) ?? []
    }

    private func saveDailyUsage(_ usage: [CharacterUsageRecord]) throws {
        let data = try jsonEncoder.encode(usage)
        try keychain.setData(data, forKey: dailyUsageKey)
    }

    private var freeUserCount: Int {
        guard let data = keychain.getData(forKey: freeCountKey),
              let string = String(data: data, encoding: .utf8),
              let count = Int(string) else { return 0 }
        return count
    }
    
    public func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws {
        if let characterLimitPerDay {
            try checkSubscribedUserLimit(estimatedCharacterCount, characterLimitPerDay: characterLimitPerDay)
        } else {
            try checkFreeUserLimit(estimatedCharacterCount)
        }
    }
    
    private func checkFreeUserLimit(_ count: Int) throws {
        guard freeUserCount + count <= freeUserLimit else {
            throw UserLimitsDataStoreError.freeUserCharacterLimitReached
        }
    }
    
    private func checkSubscribedUserLimit(_ count: Int, characterLimitPerDay: Int) throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(-86400)
        let records = dailyUsage.filter { $0.timestamp > cutoff }
        
        let totalUsage = records.reduce(0) { $0 + $1.characterCount }
        
        guard totalUsage + count <= characterLimitPerDay else {
            let timeString = records.compactMap(\.timestamp).min()
                .map(timeRemaining) ?? "24 hours"
            throw UserLimitsDataStoreError.characterLimitReached(timeUntilNextAvailable: timeString)
        }
    }
    
    public func getRemainingFreeCharacters() -> Int {
        return max(0, freeUserLimit - freeUserCount)
    }
    
    public func getTimeUntilNextDailyReset(characterLimitPerDay: Int) -> String? {
        let now = Date()
        let cutoff = now.addingTimeInterval(-86400)
        let records = dailyUsage.filter { $0.timestamp > cutoff }
        
        let totalUsage = records.reduce(0) { $0 + $1.characterCount }
        
        guard totalUsage >= characterLimitPerDay else { return nil }
        
        return records.compactMap(\.timestamp).min()
            .map(timeRemaining) ?? LocalizedString.twentyFourHours
    }
    
    public func getRemainingDailyCharacters(characterLimitPerDay: Int) -> Int {
        let now = Date()
        let cutoff = now.addingTimeInterval(-86400)
        let records = dailyUsage.filter { $0.timestamp > cutoff }
        
        let totalUsage = records.reduce(0) { $0 + $1.characterCount }
        
        return max(0, characterLimitPerDay - totalUsage)
    }
}
