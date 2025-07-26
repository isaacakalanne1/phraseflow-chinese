//
//  FlowTaleReducer.swift
//  FlowTale
//
//  Created by Claude on 26/07/2025.
//

import Foundation
import Audio
import Story
import Settings
import Study
import Translation
import Subscription
import SnackBar
import UserLimit
import Moderation
import Navigation
import Loading

func flowTaleReducer(state: FlowTaleState, action: FlowTaleAction) -> FlowTaleState {
    var newState = state
    
    switch action {
    case .audioAction(let audioAction):
        newState.audioState = audioReducer(state: state.audioState, action: audioAction)
        
    case .storyAction(let storyAction):
        newState.storyState = storyReducer(state: state.storyState, action: storyAction)
        
    case .settingsAction(let settingsAction):
        newState.settingsState = settingsReducer(state: state.settingsState, action: settingsAction)
        
    case .studyAction(let studyAction):
        newState.studyState = studyReducer(state: state.studyState, action: studyAction)
        
    case .translationAction(let translationAction):
        newState.translationState = translationReducer(state: state.translationState, action: translationAction)
        
    case .subscriptionAction(let subscriptionAction):
        newState.subscriptionState = subscriptionReducer(state: state.subscriptionState, action: subscriptionAction)
        
    case .snackBarAction(let snackBarAction):
        newState.snackBarState = snackbarReducer(state: state.snackBarState, action: snackBarAction)
        
    case .userLimitAction(let userLimitAction):
        newState.userLimitState = userLimitReducer(state: state.userLimitState, action: userLimitAction)
        
    case .moderationAction(let moderationAction):
        newState.moderationState = moderationReducer(state: state.moderationState, action: moderationAction)
        
    case .navigationAction(let navigationAction):
        newState.navigationState = navigationReducer(state: state.navigationState, action: navigationAction)
        
    case .loadingAction(let loadingAction):
        newState.loadingState = loadingReducer(state: state.loadingState, action: loadingAction)
        
    case .viewAction(let viewAction):
        newState.viewState = viewReducer(state: state.viewState, action: viewAction)
        
    case .loadAppSettings:
        newState.viewState.isInitialisingApp = false
        
    case .playSound:
        break
    }
    
    return newState
}

func viewReducer(state: ViewState, action: ViewAction) -> ViewState {
    var newState = state
    
    switch action {
    case .setInitializingApp(let value):
        newState.isInitialisingApp = value
        
    case .setContentTab(let tab):
        newState.contentTab = tab
        
    case .setSubscriptionSheetShowing(let value):
        newState.isShowingSubscriptionSheet = value
        
    case .setDailyLimitExplanationShowing(let value):
        newState.isShowingDailyLimitExplanation = value
        
    case .setFreeLimitExplanationShowing(let value):
        newState.isShowingFreeLimitExplanation = value
        
    case .setDefining(let value):
        newState.isDefining = value
        
    case .setWritingChapter(let value):
        newState.isWritingChapter = value
        
    case .setDefinitionViewId(let id):
        newState.definitionViewId = id
        
    case .setShowingCustomPromptAlert(let value):
        newState.isShowingCustomPromptAlert = value
    }
    
    return newState
}