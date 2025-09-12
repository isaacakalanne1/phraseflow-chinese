//
//  AppSettingsMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit
import UserLimit

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
         .updateShowDefinition,
         .updateShowEnglish,
         .updateDifficulty,
         .updateShouldPlaySound:
        return .saveAppSettings
        
    case .onLoadedAppSettings(let settings):
        return .loadUsageData
        
    case .playSound(let sound):
        if state.shouldPlaySound {
            environment.playSound(sound)
        }
        return nil
        
    case .playMusic(let music):
        try? environment.playMusic(music)
        return .saveAppSettings
        
    case .stopMusic:
        environment.stopMusic()
        return .saveAppSettings
        
    case .deleteCustomPrompt:
        return .saveAppSettings
        
    case .loadUsageData:
        let characterLimitPerDay = state.characterLimitPerDay
        let isSubscribed = characterLimitPerDay != nil
        
        if isSubscribed {
            let remainingCharacters = environment.userLimitEnvironment.getRemainingDailyCharacters(characterLimitPerDay: characterLimitPerDay!)
            let timeUntilReset = environment.userLimitEnvironment.getTimeUntilNextDailyReset(characterLimitPerDay: characterLimitPerDay!)
            return .onLoadedUsageData(
                remainingCharacters: remainingCharacters,
                isSubscribed: true,
                timeUntilReset: timeUntilReset
            )
        } else {
            let remainingCharacters = environment.userLimitEnvironment.getRemainingFreeCharacters()
            return .onLoadedUsageData(
                remainingCharacters: remainingCharacters,
                isSubscribed: false,
                timeUntilReset: nil
            )
        }
    case .onLoadedUsageData:
        return state.isPlayingMusic ? .playMusic(.whispersOfTheForest) : nil
    case .failedToLoadAppSettings,
         .failedToSaveAppSettings,
         .updateCustomPrompt,
         .updateIsShowingCustomPromptAlert,
         .updateStorySetting,
         .updateIsShowingModerationFailedAlert,
         .updateIsShowingModerationDetails,
         .snackbarAction:
        return nil
    }
}
