//
//  TranslationAction.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Foundation
import Settings
import Study
import TextGeneration

enum TranslationAction {
    case updateInputText(String)
    case updateSourceLanguage(Language)
    case updateTargetLanguage(Language)
    case updateTranslationMode(TranslationMode)
    case swapLanguages
    case translateText
    case breakdownText
    case translationInProgress(Bool)
    case synthesizeAudio(Chapter, Language)
    case onSynthesizedTranslationAudio(Chapter)
    case failedToSynthesizeAudio
    case failedToTranslate
    case failedToBreakdown
    case playTranslationAudio
    case pauseTranslationAudio
    case updateTranslationPlayTime
    case selectTranslationWord(WordTimeStampData)
    case playTranslationWord(WordTimeStampData)
    case clearTranslation
    case saveCurrentTranslation
    case loadTranslationHistory
    case deleteTranslation(UUID)
    case onTranslationsSaved([Chapter])
    case onTranslationsLoaded([Chapter])
    case refreshAppSettings(SettingsState)
    case saveAppSettings
    case onSavedAppSettings
    case failedToSaveAppSettings
    case showTextPractice(Bool)
}
