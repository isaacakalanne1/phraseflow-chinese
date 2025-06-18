//
//  AppSettingsReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

let appSettingsReducer: Reducer<FlowTaleState, AppSettingsAction> = { state, action in
    var newState = state

    switch action {
    case .onLoadedAppSettings(let settings):
        newState.settingsState = settings
        newState.translationState.targetLanguage = settings.language
        
    case .updateSpeechSpeed(let speed):
        newState.settingsState.speechSpeed = speed
        if newState.audioState.audioPlayer.rate != 0 {
            newState.audioState.audioPlayer.rate = speed.playRate
        }
        
    case .updateShowDefinition(let isShowing):
        newState.settingsState.isShowingDefinition = isShowing
        
    case .updateShowEnglish(let isShowing):
        newState.settingsState.isShowingEnglish = isShowing
        
    case .selectVoice(let voice):
        newState.settingsState.voice = voice
        
    case .updateDifficulty(let difficulty):
        newState.settingsState.difficulty = difficulty
        
    case .updateLanguage(let language):
        if language != newState.settingsState.language {
            newState.settingsState.language = language
            if let voice = language.voices.first {
                newState.settingsState.voice = voice
            }
        }
        
    case .updateCustomPrompt(let prompt):
        newState.settingsState.customPrompt = prompt
        
    case .updateStorySetting(let setting):
        switch setting {
        case .random:
            newState.settingsState.storySetting = setting
        case .customPrompt(let prompt):
            let isExistingPrompt = state.settingsState.customPrompts.contains(prompt)
            if isExistingPrompt {
                newState.settingsState.storySetting = setting
            }
        }
        newState.settingsState.storySetting = setting
        
    case .updateIsShowingCustomPromptAlert(let isShowing):
        newState.viewState.isShowingCustomPromptAlert = isShowing
        
    case .deleteCustomPrompt(let prompt):
        newState.settingsState.customPrompts.removeAll(where: { $0 == prompt })
        if newState.settingsState.storySetting == .customPrompt(prompt) {
            newState.settingsState.storySetting = .random
        }
        
    case .updateColorScheme(let colorScheme):
        newState.settingsState.appColorScheme = colorScheme
        
    case .updateShouldPlaySound(let shouldPlaySound):
        newState.settingsState.shouldPlaySound = shouldPlaySound
        
    case .loadAppSettings,
         .saveAppSettings,
         .failedToLoadAppSettings,
         .failedToSaveAppSettings:
        break
    }

    return newState
}