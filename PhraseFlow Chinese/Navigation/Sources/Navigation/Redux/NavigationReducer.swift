//
//  NavigationReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import AVKit

@MainActor
let navigationReducer: Reducer<NavigationState, NavigationAction> = { state, action in
    var newState = state

    switch action {
        
    case .selectTab(let tab, _):
        newState.contentTab = tab
        
    case .showFreeLimitExplanation:
        newState.isShowingFreeLimitExplanation = true
        newState.isShowingDailyLimitExplanation = false
        
    case .showDailyLimitExplanation(let nextAvailable):
        newState.isShowingDailyLimitExplanation = true
        newState.isShowingFreeLimitExplanation = false
        newState.dailyLimitNextAvailable = nextAvailable
        
    case .dismissLimitExplanation:
        newState.isShowingFreeLimitExplanation = false
        newState.isShowingDailyLimitExplanation = false
        newState.dailyLimitNextAvailable = ""
    }

    return newState
}
