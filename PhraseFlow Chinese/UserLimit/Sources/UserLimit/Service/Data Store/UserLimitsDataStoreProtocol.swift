//
//  UserLimitsDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

public protocol UserLimitsDataStoreProtocol {
    func trackSSMLCharacterUsage(characterCount: Int, characterLimitPerDay: Int?) throws
    func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws
    func getUsedFreeCharacters() -> Int
    func getTimeUntilNextDailyReset(characterLimitPerDay: Int) -> String?
    func getUsedDailyCharacters(characterLimitPerDay: Int) -> Int
}
