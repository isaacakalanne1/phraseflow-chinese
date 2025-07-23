//
//  UserLimitMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

@MainActor
let userLimitMiddleware: Middleware<UserLimitState, UserLimitAction, UserLimitEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .onDailyChapterLimitReached(let nextAvailable):
        return .snackbarAction(.showSnackBar(.dailyChapterLimitReached(nextAvailable: nextAvailable)))
        
    case .checkFreeTrialLimit,
         .hasReachedFreeTrialLimit,
         .hasReachedDailyLimit,
         .showFreeLimitExplanationScreen,
         .showDailyLimitExplanationScreen:
        return nil
    }
}
