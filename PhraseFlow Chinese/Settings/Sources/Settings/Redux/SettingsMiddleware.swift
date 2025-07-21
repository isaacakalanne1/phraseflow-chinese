//
//  AppSettingsMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

@MainActor
let settingsMiddleware: Middleware<SettingsState, SettingsAction,  SettingsEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .loadAppSettings:
        do {
            let settings = try environment.loadAppSettings()
            return .onLoadedAppSettings(settings)
        } catch {
            return .failedToLoadAppSettings
        }
        
    case .saveAppSettings:
        do {
            try environment.saveAppSettings(state)
            return nil
        } catch {
            return .failedToSaveAppSettings
        }
        
    case .selectVoice,
         .updateLanguage,
         .updateSpeechSpeed,
         .updateShowDefinition,
         .updateShowEnglish,
         .updateDifficulty,
         .updateColorScheme,
         .updateShouldPlaySound:
        return .appSettingsAction(.saveAppSettings)
        
    case .onLoadedAppSettings:
        if state.settingsState.isPlayingMusic {
            return .audioAction(.playMusic(.whispersOfTheForest))
        }
        return nil
        
    case .updateStorySetting(let setting):
        switch setting {
        case .random:
            return nil
        case .customPrompt(let prompt):
            let isNewPrompt = !state.settingsState.customPrompts.contains(prompt)
            return isNewPrompt ? .moderationAction(.moderateText(prompt)) : nil
        }
        
    case .deleteCustomPrompt:
        return .appSettingsAction(.saveAppSettings)
        
    case .failedToLoadAppSettings,
         .failedToSaveAppSettings,
         .updateCustomPrompt,
         .updateIsShowingCustomPromptAlert:
        return nil
    }
}
