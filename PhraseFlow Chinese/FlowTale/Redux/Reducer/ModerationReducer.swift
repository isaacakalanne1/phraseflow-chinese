//
//  ModerationReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

let moderationReducer: Reducer<FlowTaleState, ModerationAction> = { state, action in
    var newState = state

    switch action {
    case .onModeratedText(let response, _):
        newState.moderationResponse = response
        
    case .passedModeration(let prompt):
        newState.settingsState.customPrompts.append(prompt)
        newState.settingsState.storySetting = .customPrompt(prompt)
        
    case .didNotPassModeration:
        newState.viewState.isShowingModerationFailedAlert = true
        
    case .dismissFailedModerationAlert:
        newState.viewState.isShowingModerationFailedAlert = false
        
    case .showModerationDetails:
        newState.viewState.isShowingModerationFailedAlert = false
        newState.viewState.isShowingModerationDetails = true
        
    case .updateIsShowingModerationDetails(let isShowing):
        newState.viewState.isShowingModerationDetails = isShowing
        
    case .moderateText,
         .failedToModerateText:
        break
    }

    return newState
}
