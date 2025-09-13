//
//  UserLimitEnvironmentProtocol.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 24/07/2025.
//

import DataStorage
import Combine
import Foundation

public protocol UserLimitEnvironmentProtocol {
    var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never> { get}
    var usedCharactersSubject: CurrentValueSubject<Int?, Never> { get }

    func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws
    func getRemainingFreeCharacters() -> Int
    func getTimeUntilNextDailyReset(characterLimitPerDay: Int) -> String?
    func getRemainingDailyCharacters(characterLimitPerDay: Int) -> Int
    func getUsedFreeCharacters() -> Int
    func getUsedDailyCharacters() -> Int
    func trackSSMLCharacterUsage(characterCount: Int,
                                 subscription: SubscriptionLevel) throws -> Int
}
