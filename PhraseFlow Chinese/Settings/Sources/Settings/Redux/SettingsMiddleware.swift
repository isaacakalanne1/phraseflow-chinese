//
//  AppSettingsMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit
import Moderation

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
        return state.isPlayingMusic && !environment.isPlayingMusic ? .playMusic(.whispersOfTheForest) : nil
        
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
        
    case .updateStorySetting,
            .deleteCustomPrompt:
        return .saveAppSettings
        
    case .submitCustomPrompt(let prompt):
        do {
            let response = try await environment.moderateText(prompt)
            if response.didPassModeration {
                return .updateStorySetting(.customPrompt(prompt))
            } else {
                return .updateModerationResponse(response)
            }
        } catch {
            return .updateIsShowingModerationFailedAlert(true)
        }
        
    case .failedToLoadAppSettings,
         .failedToSaveAppSettings,
         .updateCustomPrompt,
         .updateIsShowingCustomPromptAlert,
         .updateIsShowingModerationFailedAlert,
         .updateIsShowingModerationDetails,
         .updateModerationResponse,
         .snackbarAction,
         .refreshAppSettings:
        return nil
    }
}
