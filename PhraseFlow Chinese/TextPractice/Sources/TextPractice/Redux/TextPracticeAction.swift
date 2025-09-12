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
    case playWord(WordTimeStampData)
    case defineWord(WordTimeStampData)
    case onDefinedWord(Definition)
    case failedToDefineWord
    case clearDefinition
    
    case generateDefinitions(Chapter, sentenceIndex: Int)
    case onGeneratedDefinitions([Definition], chapter: Chapter, sentenceIndex: Int)
    case failedToLoadDefinitions
    
    case goToNextChapter
    case setPlaybackTime(Double)
    case updateCurrentSentence(Sentence)
    
    case prepareToPlayChapter(Chapter)
    case playChapter(fromWord: WordTimeStampData)
    case pauseChapter
    
    // Used by subscriber to set the stored settings to the reducer
    case refreshAppSettings(SettingsState)
    // Used to save settings in the Settings package
    case saveAppSettings(SettingsState)
    
    // Load existing definitions from storage
    case loadDefinitions
    case onLoadedDefinitions([Definition])
}
