//
//  UserLimitReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

let userLimitReducer: Reducer<FlowTaleState, UserLimitAction> = { state, action in
    var newState = state

    switch action {
    case .hasReachedFreeTrialLimit:
        newState.subscriptionState.hasReachedFreeTrialLimit = true
        
    case .onDailyChapterLimitReached(let nextAvailable):
        newState.subscriptionState.nextAvailableDescription = nextAvailable
        
    case .showDailyLimitExplanationScreen(let isShowing):
        newState.viewState.isShowingDailyLimitExplanation = isShowing
        
    case .showFreeLimitExplanationScreen(let isShowing):
        newState.viewState.isShowingFreeLimitExplanation = isShowing
        
    case .checkFreeTrialLimit,
         .hasReachedDailyLimit:
        break
    }

    return newState
}