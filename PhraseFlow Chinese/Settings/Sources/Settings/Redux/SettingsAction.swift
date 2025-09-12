//
//  AppSettingsAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Audio
import Foundation
import SnackBar
import DataStorage

enum SettingsAction: Sendable {
    case loadAppSettings
    case onLoadedAppSettings(SettingsState)
    case failedToLoadAppSettings
    
    case saveAppSettings
    case failedToSaveAppSettings
    
    case selectVoice(Voice)
    case updateLanguage(Language)
    case updateShowDefinition(Bool)
    case updateShowEnglish(Bool)
    case updateDifficulty(Difficulty)
    case updateShouldPlaySound(Bool)
    
    case updateStorySetting(StorySetting)
    case updateCustomPrompt(String)
    case deleteCustomPrompt(String)
    case updateIsShowingCustomPromptAlert(Bool)
    
    case playSound(AppSound)
    case playMusic(MusicType)
    case stopMusic
    
    // SnackBar actions
    case snackbarAction(SnackBarAction)
    
    // Simple moderation actions without dependency
    case updateIsShowingModerationFailedAlert(Bool)
    case updateIsShowingModerationDetails(Bool)
    
    // User limit actions
    case loadUsageData
    case onLoadedUsageData(remainingCharacters: Int, isSubscribed: Bool, timeUntilReset: String?)
    case setCharacterLimit(Int)
    case updateSubscriptionLevel(SubscriptionLevel?)
}
