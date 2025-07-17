//
//  UserLimitAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum UserLimitAction {
    case checkFreeTrialLimit
    case hasReachedFreeTrialLimit
    case hasReachedDailyLimit
    case showFreeLimitExplanationScreen(isShowing: Bool)
    case showDailyLimitExplanationScreen(isShowing: Bool)
    case onDailyChapterLimitReached(nextAvailable: String)
}