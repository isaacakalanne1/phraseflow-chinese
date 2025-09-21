//
//  SubscriptionLevelTests.swift
//  DataStorage
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
@testable import DataStorage

class SubscriptionLevelTests {
    
    @Test
    func ssmlCharacterLimitPerDay_free_debugMode() {
        let subscriptionLevel = SubscriptionLevel.free
        
        #if DEBUG
        #expect(subscriptionLevel.ssmlCharacterLimitPerDay == 9_999_999)
        #else
        #expect(subscriptionLevel.ssmlCharacterLimitPerDay == 4000)
        #endif
    }
    
    @Test
    func ssmlCharacterLimitPerDay_level1() {
        let subscriptionLevel = SubscriptionLevel.level1
        #expect(subscriptionLevel.ssmlCharacterLimitPerDay == 15000)
    }
    
    @Test
    func ssmlCharacterLimitPerDay_level2() {
        let subscriptionLevel = SubscriptionLevel.level2
        #expect(subscriptionLevel.ssmlCharacterLimitPerDay == 30000)
    }
    
    @Test
    func idString_free() {
        let subscriptionLevel = SubscriptionLevel.free
        #expect(subscriptionLevel.idString == "")
    }
    
    @Test
    func idString_level1() {
        let subscriptionLevel = SubscriptionLevel.level1
        #expect(subscriptionLevel.idString == "com.flowtale.level_1")
    }
    
    @Test
    func idString_level2() {
        let subscriptionLevel = SubscriptionLevel.level2
        #expect(subscriptionLevel.idString == "com.flowtale.level_2")
    }
    
    @Test
    func initWithId_free() {
        let subscriptionLevel = SubscriptionLevel(id: "")
        #expect(subscriptionLevel == .free)
    }
    
    @Test
    func initWithId_level1() {
        let subscriptionLevel = SubscriptionLevel(id: "com.flowtale.level_1")
        #expect(subscriptionLevel == .level1)
    }
    
    @Test
    func initWithId_level2() {
        let subscriptionLevel = SubscriptionLevel(id: "com.flowtale.level_2")
        #expect(subscriptionLevel == .level2)
    }
    
    @Test
    func initWithId_invalidId_returnsNil() {
        let subscriptionLevel = SubscriptionLevel(id: "invalid.id")
        #expect(subscriptionLevel == nil)
    }
    
    @Test
    func initWithId_emptyStringAfterFree_returnsNil() {
        let subscriptionLevel = SubscriptionLevel(id: "com.flowtale.invalid")
        #expect(subscriptionLevel == nil)
    }
    
    @Test
    func allCases_containsAllLevels() {
        let allCases = SubscriptionLevel.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.free))
        #expect(allCases.contains(.level1))
        #expect(allCases.contains(.level2))
    }
    
    @Test
    func equatable_sameLevels() {
        #expect(SubscriptionLevel.free == SubscriptionLevel.free)
        #expect(SubscriptionLevel.level1 == SubscriptionLevel.level1)
        #expect(SubscriptionLevel.level2 == SubscriptionLevel.level2)
    }
    
    @Test
    func equatable_differentLevels() {
        #expect(SubscriptionLevel.free != SubscriptionLevel.level1)
        #expect(SubscriptionLevel.level1 != SubscriptionLevel.level2)
        #expect(SubscriptionLevel.free != SubscriptionLevel.level2)
    }
}
