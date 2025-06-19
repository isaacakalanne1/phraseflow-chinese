//
//  UserLimitMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

let userLimitMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .userLimitAction(let userLimitAction):
        switch userLimitAction {
        case .onDailyChapterLimitReached(let nextAvailable):
            return .snackbarAction(.showSnackBar(.dailyChapterLimitReached(nextAvailable: nextAvailable)))
            
        case .checkFreeTrialLimit,
             .hasReachedFreeTrialLimit,
             .hasReachedDailyLimit,
             .showFreeLimitExplanationScreen,
             .showDailyLimitExplanationScreen:
            return nil
        }
    default:
        return nil
    }
}
