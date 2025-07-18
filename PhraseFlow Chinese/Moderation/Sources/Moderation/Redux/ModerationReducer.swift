//
//  ModerationReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

@MainActor
let moderationReducer: Reducer<ModerationState, ModerationAction> = { state, action in
    var newState = state

    switch action {
    case .onModeratedText(let response, _):
        newState.moderationResponse = response
        
    case .didNotPassModeration:
        newState.isShowingModerationFailedAlert = true
        
    case .dismissFailedModerationAlert:
        newState.isShowingModerationFailedAlert = false
        
    case .showModerationDetails:
        newState.isShowingModerationFailedAlert = false
        newState.isShowingModerationDetails = true
        
    case .updateIsShowingModerationDetails(let isShowing):
        newState.isShowingModerationDetails = isShowing
        
    case .moderateText,
         .passedModeration,
         .failedToModerateText:
        break
    }

    return newState
}
