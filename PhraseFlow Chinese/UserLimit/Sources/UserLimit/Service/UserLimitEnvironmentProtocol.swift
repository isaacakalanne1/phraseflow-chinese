//
//  UserLimitEnvironmentProtocol.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 24/07/2025.
//

import Combine
import Foundation

public protocol UserLimitEnvironmentProtocol {
    var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never> { get}
    func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws
    func getRemainingFreeCharacters() -> Int
    func getTimeUntilNextDailyReset(characterLimitPerDay: Int) -> String?
    func getRemainingDailyCharacters(characterLimitPerDay: Int) -> Int
}
