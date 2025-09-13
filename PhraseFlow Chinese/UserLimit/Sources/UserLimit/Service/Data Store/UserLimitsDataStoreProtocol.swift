//
//  UserLimitsDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import DataStorage
import Foundation

public protocol UserLimitsDataStoreProtocol {
    func trackSSMLCharacterUsage(characterCount: Int, subscription: SubscriptionLevel) throws -> Int
    func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws
    func getUsedFreeCharacters() -> Int
    func getUsedDailyCharacters() -> Int
    func getTimeUntilNextDailyReset(characterLimitPerDay: Int) -> String?
}
