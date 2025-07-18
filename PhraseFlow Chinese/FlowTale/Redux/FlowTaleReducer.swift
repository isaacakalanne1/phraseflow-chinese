//
//  FlowTaleReducer.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit
import Audio
import Story
import Settings
import Definition
import Study
import Translation
import Subscription
import SnackBar
import UserLimit
import Moderation
import Navigation

let flowTaleReducer: Reducer<FlowTaleState, FlowTaleAction> = { state, action in
    var newState = state
    
    switch action {
    case .audioAction(let audioAction):
        newState.audioState = audioReducer(newState.audioState, audioAction)
        
        // Handle cross-package effects for audio actions
        switch audioAction {
        case .playMusic:
            newState.settingsState.isPlayingMusic = true
        case .stopMusic:
            newState.settingsState.isPlayingMusic = false
        case .playAudio:
            newState.definitionState.currentDefinition = nil
            // Story state updates handled in middleware
        case .updatePlayTime:
            // Story state updates handled in middleware
        default:
            break
        }
        
    case .storyAction(let storyAction):
        newState = storyReducer(newState, storyAction)
        
    case .appSettingsAction(let settingsAction):
        newState = appSettingsReducer(newState, settingsAction)
        
        // Handle cross-package effects for settings actions
        switch settingsAction {
        case .updateSpeechSpeed(let speed):
            newState.audioState.speechSpeed = speed
            // Apply speed to audio player if it's playing
            if newState.audioState.chapterAudioPlayer.rate != 0 {
                newState.audioState.chapterAudioPlayer.rate = speed.playRate
            }
        default:
            break
        }
        
    case .definitionAction(let definitionAction):
        newState.definitionState = definitionReducer(newState.definitionState, definitionAction)
        
        // Handle cross-package effects for definition actions
        switch definitionAction {
        case .onShownDefinition:
            newState.viewState.isDefining = false
        case .defineSentence(let index, _):
            newState.viewState.loadingState = .complete
            if index >= 1 {
                newState.viewState.isWritingChapter = false
            }
        case .refreshDefinitionView:
            newState.viewState.definitionViewId = UUID()
        default:
            break
        }
        
    case .studyAction(let studyAction):
        newState = studyReducer(newState, studyAction)
        
    case .translationAction(let translationAction):
        newState = translationReducer(newState, translationAction)
        
    case .subscriptionAction(let subscriptionAction):
        newState = subscriptionReducer(newState, subscriptionAction)
        
    case .snackbarAction(let snackbarAction):
        newState = snackbarReducer(newState, snackbarAction)
        
    case .userLimitAction(let userLimitAction):
        newState = userLimitReducer(newState, userLimitAction)
        
    case .moderationAction(let moderationAction):
        newState.moderationState = moderationReducer(newState.moderationState, moderationAction)
        
        // Handle cross-package effects for moderation actions
        switch moderationAction {
        case .passedModeration(let prompt):
            newState.settingsState.customPrompts.append(prompt)
            newState.settingsState.storySetting = .customPrompt(prompt)
        default:
            break
        }
        
    case .navigationAction(let navigationAction):
        newState.navigationState = navigationReducer(newState.navigationState, navigationAction)
    }
    
    return newState
}