//
//  TextPracticeAction.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import Audio
import TextGeneration
import Settings
import Study
import AVKit

public enum TextPracticeAction: Sendable, Equatable {
    case addDefinitions([Definition])
    case showDefinition(WordTimeStampData)
    case hideDefinition
    case selectWord(WordTimeStampData)
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
    
    case setChapter(Chapter)
    case prepareToPlayChapter
    case setChapterAudioData(Data)
    case onCreatedChapterPlayer(AVPlayer)
    case playChapterAudio(time: Double?, rate: Float)
    case pauseChapterAudio
    case updatePlaybackRate(Float)
    case playChapter(fromWord: WordTimeStampData)
    case pauseChapter
    
    // Used by subscriber to set the stored settings to the reducer
    case refreshAppSettings(SettingsState)
    // Used to save settings in the Settings package
    case saveAppSettings(SettingsState)
    case playSound(AppSound)
}
