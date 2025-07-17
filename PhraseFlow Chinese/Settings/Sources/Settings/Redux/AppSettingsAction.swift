//
//  AppSettingsAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum AppSettingsAction {
    case loadAppSettings
    case onLoadedAppSettings(SettingsState)
    case failedToLoadAppSettings
    
    case saveAppSettings
    case failedToSaveAppSettings
    
    case selectVoice(Voice)
    case updateLanguage(Language)
    case updateSpeechSpeed(SpeechSpeed)
    case updateShowDefinition(Bool)
    case updateShowEnglish(Bool)
    case updateDifficulty(Difficulty)
    case updateColorScheme(FlowTaleColorScheme)
    case updateShouldPlaySound(Bool)
    
    case updateStorySetting(StorySetting)
    case updateCustomPrompt(String)
    case deleteCustomPrompt(String)
    case updateIsShowingCustomPromptAlert(Bool)
}