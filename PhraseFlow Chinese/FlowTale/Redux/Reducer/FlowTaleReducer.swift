//
//  FlowTaleReducer.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import SwiftUI
import ReduxKit
import AVKit
import StoreKit

let flowTaleReducer: Reducer<FlowTaleState, FlowTaleAction> = { state, action in
    var newState = state

    switch action {
    case .studyAction(let studyAction):
        newState.studyState = studyReducer(state.studyState, studyAction)
        
    case .translationAction(let translationAction):
        newState.translationState = translationReducer(state.translationState, translationAction)
        
    case .storyAction(let storyAction):
        newState = storyReducer(state, storyAction)
        
    case .audioAction(let audioAction):
        newState = audioReducer(state, audioAction)

    case .subscriptionAction(let subscriptionAction):
        newState = subscriptionReducer(state, subscriptionAction)

    case .definitionAction(let definitionAction):
        newState = definitionReducer(state, definitionAction)
        
    case .appSettingsAction(let appSettingsAction):
        newState = appSettingsReducer(state, appSettingsAction)
        
    case .moderationAction(let moderationAction):
        newState = moderationReducer(state, moderationAction)
        
    case .userLimitAction(let userLimitAction):
        newState = userLimitReducer(state, userLimitAction)
        
    case .navigationAction(let navigationAction):
        newState = navigationReducer(state, navigationAction)
        
    case .snackbarAction(let snackbarAction):
        newState = snackbarReducer(state, snackbarAction)
    }

    return newState
}
