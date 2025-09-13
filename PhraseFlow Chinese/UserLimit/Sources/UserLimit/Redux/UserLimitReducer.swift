//
//  UserLimitReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

@MainActor
let userLimitReducer: Reducer<UserLimitState, UserLimitAction> = { state, action in
    var newState = state

    switch action {

    case .hasReachedFreeTrialLimit:
        newState.hasReachedFreeTrialLimit = true

    case .onDailyChapterLimitReached(let nextAvailable):
        newState.nextAvailableDescription = nextAvailable

    case .showDailyLimitExplanationScreen(let isShowing):
        newState.isShowingDailyLimitExplanation = isShowing

    case .showFreeLimitExplanationScreen(let isShowing):
        newState.isShowingFreeLimitExplanation = isShowing

    case .checkFreeTrialLimit,
         .hasReachedDailyLimit:
        break
    }

    return newState
}
