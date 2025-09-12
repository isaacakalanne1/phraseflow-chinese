//
//  UserLimitEnvironmentProtocol.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 24/07/2025.
//

import Foundation

public protocol UserLimitEnvironmentProtocol {
    func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws
    func getRemainingFreeCharacters() -> Int
    func getTimeUntilNextDailyReset(characterLimitPerDay: Int) -> String?
    func getRemainingDailyCharacters(characterLimitPerDay: Int) -> Int
}
