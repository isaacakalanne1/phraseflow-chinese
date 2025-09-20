//
//  MockUserLimitsDataStore.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import DataStorage
import Foundation
import UserLimit

enum MockUserLimitsDataStoreError: Error {
    case genericError
}

public class MockUserLimitsDataStore: UserLimitsDataStoreProtocol {
    
    public init() {
        
    }
    
    var trackSSMLCharacterUsageCharacterCountSpy: Int?
    var trackSSMLCharacterUsageSubscriptionSpy: SubscriptionLevel?
    var trackSSMLCharacterUsageCalled = false
    var trackSSMLCharacterUsageResult: Result<Int, MockUserLimitsDataStoreError> = .success(0)
    public func trackSSMLCharacterUsage(characterCount: Int, subscription: SubscriptionLevel) throws -> Int {
        trackSSMLCharacterUsageCharacterCountSpy = characterCount
        trackSSMLCharacterUsageSubscriptionSpy = subscription
        trackSSMLCharacterUsageCalled = true
        switch trackSSMLCharacterUsageResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var canCreateChapterEstimatedCharacterCountSpy: Int?
    var canCreateChapterCharacterLimitPerDaySpy: Int?
    var canCreateChapterCalled = false
    var canCreateChapterResult: Result<Void, MockUserLimitsDataStoreError> = .success(())
    public func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws {
        canCreateChapterEstimatedCharacterCountSpy = estimatedCharacterCount
        canCreateChapterCharacterLimitPerDaySpy = characterLimitPerDay
        canCreateChapterCalled = true
        switch canCreateChapterResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var getUsedFreeCharactersCalled = false
    var getUsedFreeCharactersReturn = 0
    public func getUsedFreeCharacters() -> Int {
        getUsedFreeCharactersCalled = true
        return getUsedFreeCharactersReturn
    }
    
    var getUsedDailyCharactersCalled = false
    var getUsedDailyCharactersReturn = 0
    public func getUsedDailyCharacters() -> Int {
        getUsedDailyCharactersCalled = true
        return getUsedDailyCharactersReturn
    }
    
    var getTimeUntilNextDailyResetCharacterLimitPerDaySpy: Int?
    var getTimeUntilNextDailyResetCalled = false
    var getTimeUntilNextDailyResetReturn: String? = nil
    public func getTimeUntilNextDailyReset(characterLimitPerDay: Int) -> String? {
        getTimeUntilNextDailyResetCharacterLimitPerDaySpy = characterLimitPerDay
        getTimeUntilNextDailyResetCalled = true
        return getTimeUntilNextDailyResetReturn
    }
}