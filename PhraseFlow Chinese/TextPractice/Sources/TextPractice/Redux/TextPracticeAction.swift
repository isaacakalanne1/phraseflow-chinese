//
//  TextPracticeAction.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import TextGeneration
import Settings
import Study

public enum TextPracticeAction: Sendable {
    case setChapter(Chapter)
    
    case addDefinitions([Definition])
    case showDefinition(WordTimeStampData)
    case hideDefinition
    case selectWord(WordTimeStampData, playAudio: Bool)
    
    case goToNextChapter
    case setPlaybackTime(Double)
    case updateCurrentSentence(Sentence)
    
    case prepareToPlayChapter(Chapter)
    case playChapter(fromWord: WordTimeStampData)
    case pauseChapter
    
    // Used by subscriber to set the stored settings to the reducer
    case refreshSettings(SettingsState)
    // Used to save settings in the Settings package
    case saveAppSettings(SettingsState)
    // Initial loading of app settings
    case loadAppSettings
    case failedToLoadAppSettings
}
