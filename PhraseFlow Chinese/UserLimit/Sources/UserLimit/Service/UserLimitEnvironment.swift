//
//  UserLimitEnvironment.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 24/07/2025.
//

import Combine
import Foundation

public struct UserLimitEnvironment: UserLimitEnvironmentProtocol {
    private let dataStore: UserLimitsDataStoreProtocol
    public let limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never>
    
    public init(dataStore: UserLimitsDataStoreProtocol) {
        self.dataStore = dataStore
        self.limitReachedSubject = .init(.freeLimit)
    }
    
    public func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws {
        try dataStore.canCreateChapter(estimatedCharacterCount: estimatedCharacterCount, characterLimitPerDay: characterLimitPerDay)
    }
    
    public func getRemainingFreeCharacters() -> Int {
        dataStore.getRemainingFreeCharacters()
    }
    
    public func getTimeUntilNextDailyReset(characterLimitPerDay: Int) -> String? {
        dataStore.getTimeUntilNextDailyReset(characterLimitPerDay: characterLimitPerDay)
    }
    
    public func getRemainingDailyCharacters(characterLimitPerDay: Int) -> Int {
        dataStore.getRemainingDailyCharacters(characterLimitPerDay: characterLimitPerDay)
    }
}
