//
//  UserLimitEnvironmentTests.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Combine
import DataStorage
import Foundation
@testable import UserLimit
@testable import UserLimitMocks

class UserLimitEnvironmentTests {
    let environment: UserLimitEnvironmentProtocol
    let mockDataStore: MockUserLimitsDataStore
    
    init() {
        self.mockDataStore = MockUserLimitsDataStore()
        self.environment = UserLimitEnvironment(dataStore: mockDataStore)
    }
    
    @Test
    func canCreateChapter_success() throws {
        let characterCount = 1000
        let characterLimit = 5000
        
        try environment.canCreateChapter(estimatedCharacterCount: characterCount, characterLimitPerDay: characterLimit)
        
        #expect(mockDataStore.canCreateChapterEstimatedCharacterCountSpy == characterCount)
        #expect(mockDataStore.canCreateChapterCharacterLimitPerDaySpy == characterLimit)
        #expect(mockDataStore.canCreateChapterCalled == true)
    }
    
    @Test
    func canCreateChapter_error() throws {
        let characterCount = 10000
        let characterLimit = 5000
        mockDataStore.canCreateChapterResult = .failure(.genericError)
        
        do {
            try environment.canCreateChapter(estimatedCharacterCount: characterCount, characterLimitPerDay: characterLimit)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDataStore.canCreateChapterEstimatedCharacterCountSpy == characterCount)
            #expect(mockDataStore.canCreateChapterCharacterLimitPerDaySpy == characterLimit)
            #expect(mockDataStore.canCreateChapterCalled == true)
        }
    }
    
    @Test
    func canCreateChapter_nilCharacterLimit() throws {
        let characterCount = 1000
        
        try environment.canCreateChapter(estimatedCharacterCount: characterCount, characterLimitPerDay: nil)
        
        #expect(mockDataStore.canCreateChapterEstimatedCharacterCountSpy == characterCount)
        #expect(mockDataStore.canCreateChapterCharacterLimitPerDaySpy == nil)
        #expect(mockDataStore.canCreateChapterCalled == true)
    }
    
    @Test
    func getRemainingFreeCharacters() {
        let usedCharacters = 1500
        let freeLimit = SubscriptionLevel.free.ssmlCharacterLimitPerDay
        let expectedRemainingCharacters = freeLimit - usedCharacters
        mockDataStore.getUsedFreeCharactersReturn = usedCharacters
        
        let result = environment.getRemainingFreeCharacters()
        
        #expect(result == expectedRemainingCharacters)
        #expect(mockDataStore.getUsedFreeCharactersCalled == true)
    }
    
    @Test
    func getTimeUntilNextDailyReset_withResult() {
        let characterLimit = 15000
        let expectedTime = "12:34:56"
        mockDataStore.getTimeUntilNextDailyResetReturn = expectedTime
        
        let result = environment.getTimeUntilNextDailyReset(characterLimitPerDay: characterLimit)
        
        #expect(result == expectedTime)
        #expect(mockDataStore.getTimeUntilNextDailyResetCharacterLimitPerDaySpy == characterLimit)
        #expect(mockDataStore.getTimeUntilNextDailyResetCalled == true)
    }
    
    @Test
    func getTimeUntilNextDailyReset_nilResult() {
        let characterLimit = 30000
        mockDataStore.getTimeUntilNextDailyResetReturn = nil
        
        let result = environment.getTimeUntilNextDailyReset(characterLimitPerDay: characterLimit)
        
        #expect(result == nil)
        #expect(mockDataStore.getTimeUntilNextDailyResetCharacterLimitPerDaySpy == characterLimit)
        #expect(mockDataStore.getTimeUntilNextDailyResetCalled == true)
    }
    
    @Test
    func getRemainingDailyCharacters() {
        let characterLimit = 15000
        let usedCharacters = 7000
        let expectedRemaining = characterLimit - usedCharacters
        mockDataStore.getUsedDailyCharactersReturn = usedCharacters
        
        let result = environment.getRemainingDailyCharacters(characterLimitPerDay: characterLimit)
        
        #expect(result == expectedRemaining)
        #expect(mockDataStore.getUsedDailyCharactersCalled == true)
    }
    
    @Test
    func getUsedFreeCharacters() {
        let expectedUsedCharacters = 1500
        mockDataStore.getUsedFreeCharactersReturn = expectedUsedCharacters
        
        let result = environment.getUsedFreeCharacters()
        
        #expect(result == expectedUsedCharacters)
        #expect(mockDataStore.getUsedFreeCharactersCalled == true)
    }
    
    @Test
    func getUsedDailyCharacters() {
        let expectedUsedCharacters = 7000
        mockDataStore.getUsedDailyCharactersReturn = expectedUsedCharacters
        
        let result = environment.getUsedDailyCharacters()
        
        #expect(result == expectedUsedCharacters)
        #expect(mockDataStore.getUsedDailyCharactersCalled == true)
    }
    
    @Test(arguments: [
        SubscriptionLevel.free,
        SubscriptionLevel.level1,
        SubscriptionLevel.level2
    ])
    func trackSSMLCharacterUsage_success(subscription: SubscriptionLevel) throws {
        let characterCount = 500
        let expectedUsedCharacters = 2000
        mockDataStore.trackSSMLCharacterUsageResult = .success(expectedUsedCharacters)
        
        let result = try environment.trackSSMLCharacterUsage(characterCount: characterCount, subscription: subscription)
        
        #expect(result == expectedUsedCharacters)
        #expect(mockDataStore.trackSSMLCharacterUsageCharacterCountSpy == characterCount)
        #expect(mockDataStore.trackSSMLCharacterUsageSubscriptionSpy == subscription)
        #expect(mockDataStore.trackSSMLCharacterUsageCalled == true)
    }
    
    @Test(arguments: [
        SubscriptionLevel.free,
        SubscriptionLevel.level1,
        SubscriptionLevel.level2
    ])
    func trackSSMLCharacterUsage_error(subscription: SubscriptionLevel) throws {
        let characterCount = 10000
        mockDataStore.trackSSMLCharacterUsageResult = .failure(.genericError)
        
        do {
            _ = try environment.trackSSMLCharacterUsage(characterCount: characterCount, subscription: subscription)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDataStore.trackSSMLCharacterUsageCharacterCountSpy == characterCount)
            #expect(mockDataStore.trackSSMLCharacterUsageSubscriptionSpy == subscription)
            #expect(mockDataStore.trackSSMLCharacterUsageCalled == true)
        }
    }
    
    @Test
    func limitReachedSubject_initialValue() {
        #expect(environment.limitReachedSubject.value == .freeLimit)
    }
    
    @Test
    func limitReachedSubject_setValue() {
        let testEvent = LimitReachedEvent.dailyLimit(nextAvailable: "Tomorrow at 12:00 AM")
        
        environment.limitReachedSubject.send(testEvent)
        
        #expect(environment.limitReachedSubject.value == testEvent)
    }
    
    @Test
    func usedCharactersSubject_initialValue() {
        #expect(environment.usedCharactersSubject.value == nil)
    }
    
    @Test
    func usedCharactersSubject_setValue() {
        let testCharacters = 1500
        
        environment.usedCharactersSubject.send(testCharacters)
        
        #expect(environment.usedCharactersSubject.value == testCharacters)
    }
    
    @Test
    func usedCharactersSubject_setNilValue() {
        environment.usedCharactersSubject.send(500)
        environment.usedCharactersSubject.send(nil)
        
        #expect(environment.usedCharactersSubject.value == nil)
    }
}

