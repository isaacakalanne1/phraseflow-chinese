//
//  MockUserLimitEnvironment.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Combine
import DataStorage
import Foundation
import UserLimit

enum MockUserLimitEnvironmentError: Error {
    case genericError
}

public class MockUserLimitEnvironment: UserLimitEnvironmentProtocol {
    
    public var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never>
    public var usedCharactersSubject: CurrentValueSubject<Int?, Never>
    
    public init(
        limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never> = .init(.freeLimit),
        usedCharactersSubject: CurrentValueSubject<Int?, Never> = .init(nil)
    ) {
        self.limitReachedSubject = limitReachedSubject
        self.usedCharactersSubject = usedCharactersSubject
    }
    
    var canCreateChapterEstimatedCharacterCountSpy: Int?
    var canCreateChapterCharacterLimitPerDaySpy: Int?
    var canCreateChapterCalled = false
    var canCreateChapterResult: Result<Void, MockUserLimitEnvironmentError> = .success(())
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
    
    var getRemainingFreeCharactersCalled = false
    var getRemainingFreeCharactersReturn = 0
    public func getRemainingFreeCharacters() -> Int {
        getRemainingFreeCharactersCalled = true
        return getRemainingFreeCharactersReturn
    }
    
    var getTimeUntilNextDailyResetCharacterLimitPerDaySpy: Int?
    var getTimeUntilNextDailyResetCalled = false
    var getTimeUntilNextDailyResetReturn: String? = nil
    public func getTimeUntilNextDailyReset(characterLimitPerDay: Int) -> String? {
        getTimeUntilNextDailyResetCharacterLimitPerDaySpy = characterLimitPerDay
        getTimeUntilNextDailyResetCalled = true
        return getTimeUntilNextDailyResetReturn
    }
    
    var getRemainingDailyCharactersCharacterLimitPerDaySpy: Int?
    var getRemainingDailyCharactersCalled = false
    var getRemainingDailyCharactersReturn = 0
    public func getRemainingDailyCharacters(characterLimitPerDay: Int) -> Int {
        getRemainingDailyCharactersCharacterLimitPerDaySpy = characterLimitPerDay
        getRemainingDailyCharactersCalled = true
        return getRemainingDailyCharactersReturn
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
    
    var trackSSMLCharacterUsageCharacterCountSpy: Int?
    var trackSSMLCharacterUsageSubscriptionSpy: SubscriptionLevel?
    var trackSSMLCharacterUsageCalled = false
    var trackSSMLCharacterUsageResult: Result<Int, MockUserLimitEnvironmentError> = .success(0)
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
}