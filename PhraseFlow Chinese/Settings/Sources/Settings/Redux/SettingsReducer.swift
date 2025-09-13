//
//  AppSettingsReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import DataStorage

@MainActor
let settingsReducer: Reducer<SettingsState, SettingsAction> = { state, action in
    var newState = state

    switch action {
    case .onLoadedAppSettings(let settings):
        newState = settings
        
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
        
    case .updateShouldPlaySound(let shouldPlaySound):
        newState.shouldPlaySound = shouldPlaySound
        
    case .updateIsShowingModerationFailedAlert(let isShowing):
        newState.isShowingModerationFailedAlert = isShowing
        
    case .updateIsShowingModerationDetails(let isShowing):
        newState.viewState.isShowingModerationDetails = isShowing
        
    case .playMusic:
        newState.isPlayingMusic = true
    case .stopMusic:
        newState.isPlayingMusic = false
        
    case .onLoadedUsageData(let remainingCharacters, let timeUntilReset):
        newState.remainingCharacters = remainingCharacters
        newState.timeUntilReset = timeUntilReset
        
    case .updateSubscriptionLevel(let subscriptionLevel):
        newState.subscriptionLevel = subscriptionLevel
        newState.characterLimitPerDay = subscriptionLevel.ssmlCharacterLimitPerDay
        
    case .loadAppSettings,
         .saveAppSettings,
         .failedToLoadAppSettings,
         .failedToSaveAppSettings,
         .playSound,
         .snackbarAction,
         .loadUsageData:
        break
    }

    return newState
}
