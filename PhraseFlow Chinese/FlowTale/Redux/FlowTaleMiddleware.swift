//
//  FlowTaleMiddleware.swift
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

func flowTaleMiddleware(state: FlowTaleState, action: FlowTaleAction, environment: FlowTaleEnvironmentProtocol) -> FlowTaleAction? {
    switch action {
    case .audioAction(let audioAction):
        if let nextAction = audioMiddleware(state: state.audioState, action: audioAction, environment: environment.audioEnvironment) {
            return .audioAction(nextAction)
        }
        
    case .storyAction(let storyAction):
        if let nextAction = storyMiddleware(state: state.storyState, action: storyAction, environment: environment.storyEnvironment) {
            return .storyAction(nextAction)
        }
        
    case .settingsAction(let settingsAction):
        if let nextAction = settingsMiddleware(state: state.settingsState, action: settingsAction, environment: environment.settingsEnvironment) {
            return .settingsAction(nextAction)
        }
        
    case .studyAction(let studyAction):
        if let nextAction = studyMiddleware(state: state.studyState, action: studyAction, environment: environment.studyEnvironment) {
            return .studyAction(nextAction)
        }
        
    case .translationAction(let translationAction):
        if let nextAction = translationMiddleware(state: state.translationState, action: translationAction, environment: environment.translationEnvironment) {
            return .translationAction(nextAction)
        }
        
    case .subscriptionAction(let subscriptionAction):
        if let nextAction = subscriptionMiddleware(state: state.subscriptionState, action: subscriptionAction, environment: environment.subscriptionEnvironment) {
            return .subscriptionAction(nextAction)
        }
        
    case .snackBarAction(let snackBarAction):
        if let nextAction = snackbarMiddleware(state: state.snackBarState, action: snackBarAction, environment: environment.snackBarEnvironment) {
            return .snackBarAction(nextAction)
        }
        
    case .userLimitAction(let userLimitAction):
        if let nextAction = userLimitMiddleware(state: state.userLimitState, action: userLimitAction, environment: environment.userLimitEnvironment) {
            return .userLimitAction(nextAction)
        }
        
    case .moderationAction(let moderationAction):
        if let nextAction = moderationMiddleware(state: state.moderationState, action: moderationAction, environment: environment.moderationEnvironment) {
            return .moderationAction(nextAction)
        }
        
    case .navigationAction(let navigationAction):
        if let nextAction = navigationMiddleware(state: state.navigationState, action: navigationAction, environment: environment.navigationEnvironment) {
            return .navigationAction(nextAction)
        }
        
    case .loadingAction(let loadingAction):
        if let nextAction = loadingMiddleware(state: state.loadingState, action: loadingAction, environment: environment.loadingEnvironment) {
            return .loadingAction(nextAction)
        }
        
    case .loadAppSettings:
        environment.settingsEnvironment.loadSettings()
        return .viewAction(.setInitializingApp(false))
        
    case .playSound(let soundEffect):
        environment.audioEnvironment.playSound(soundEffect)
        
    case .viewAction:
        break
    }
    
    return nil
}