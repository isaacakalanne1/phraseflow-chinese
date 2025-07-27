//
//  AppSettingsReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

@MainActor
let settingsReducer: Reducer<SettingsState, SettingsAction> = { state, action in
    var newState = state

    switch action {
    case .onLoadedAppSettings(let settings):
        newState = settings
        
    case .updateSpeechSpeed(let speed):
        newState.speechSpeed = speed
        // Audio player logic now handled in AudioReducer
        
    case .updateShowDefinition(let isShowing):
        newState.isShowingDefinition = isShowing
        
    case .updateShowEnglish(let isShowing):
        newState.isShowingEnglish = isShowing
        
    case .selectVoice(let voice):
        newState.voice = voice
        
    case .updateDifficulty(let difficulty):
        newState.difficulty = difficulty
        
    case .updateLanguage(let language):
        if language != newState.language {
            newState.language = language
            if let voice = language.voices.first {
                newState.voice = voice
            }
        }
        
    case .updateCustomPrompt(let prompt):
        newState.customPrompt = prompt
        
    case .updateStorySetting(let setting):
        switch setting {
        case .random:
            newState.storySetting = setting
        case .customPrompt(let prompt):
            let isExistingPrompt = state.customPrompts.contains(prompt)
            if isExistingPrompt {
                newState.storySetting = setting
            } else {
                newState.customPrompts.append(prompt)
            }
        }
        newState.storySetting = setting
        
    case .updateIsShowingCustomPromptAlert(let isShowing):
        newState.isShowingCustomPromptAlert = isShowing
        
    case .deleteCustomPrompt(let prompt):
        newState.customPrompts.removeAll(where: { $0 == prompt })
        if newState.storySetting == .customPrompt(prompt) {
            newState.storySetting = .random
        }
        
    case .updateColorScheme(let colorScheme):
        newState.appColorScheme = colorScheme
        
    case .updateShouldPlaySound(let shouldPlaySound):
        newState.shouldPlaySound = shouldPlaySound
        
    case .updateIsShowingModerationFailedAlert(let isShowing):
        newState.isShowingModerationFailedAlert = isShowing
        
    case .updateIsShowingModerationDetails(let isShowing):
        newState.viewState.isShowingModerationDetails = isShowing
        
    case .loadAppSettings,
         .saveAppSettings,
         .failedToLoadAppSettings,
         .failedToSaveAppSettings,
         .playMusic,
         .playSound,
         .stopMusic,
         .snackbarAction:
        break
    }

    return newState
}
