//
//  UserLimitsDataStoreProtocol+Extension.swift
//  UserLimit
//
//  Created by Claude on 13/09/2025.
//

import Foundation
import DataStorage

public extension UserLimitsDataStoreProtocol {
    func getRemainingFreeCharacters() -> Int {
        let freeUserLimit = SubscriptionLevel.free.ssmlCharacterLimitPerDay
        let usedCharacters = getUsedFreeCharacters()
        return max(0, freeUserLimit - usedCharacters)
    }
    
    func getRemainingDailyCharacters(characterLimitPerDay: Int) -> Int {
        let usedCharacters = getUsedDailyCharacters(characterLimitPerDay: characterLimitPerDay)
        return max(0, characterLimitPerDay - usedCharacters)
    }
}