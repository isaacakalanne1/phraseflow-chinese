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
        return .saveAppSettings
        
    case .onLoadedAppSettings(let settings):
        return settings.isPlayingMusic ? .playMusic(.whispersOfTheForest) : nil
        
    case .playSound(let sound):
        environment.playSound(sound)
        return nil
        
    case .playMusic(let music):
        try? environment.playMusic(music)
        return nil
        
    case .stopMusic:
        environment.stopMusic()
        return nil
        
    case .deleteCustomPrompt:
        return .saveAppSettings
        
    case .failedToLoadAppSettings,
         .failedToSaveAppSettings,
         .updateCustomPrompt,
         .updateIsShowingCustomPromptAlert,
         .updateStorySetting:
        return nil
    }
}
