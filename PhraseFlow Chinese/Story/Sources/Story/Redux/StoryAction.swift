//
//  StoryAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Audio
import Study
import Foundation
import Loading
import Settings
import Speech
import TextGeneration

public enum StoryAction: Sendable {
    case createChapter(CreateChapterType)
    case onCreatedChapter(Chapter)
    case failedToCreateChapter

    case loadStoriesAndDefinitions
    case onLoadedStoriesAndDefitions([Chapter], [Definition])
    case failedToLoadStoriesAndDefinitions

    case deleteStory(UUID)
    case onDeletedStory(UUID)
    case failedToDeleteStory

    case saveChapter(Chapter)
    case onSavedChapter(Chapter)
    case failedToSaveChapter
    
    case beginGetNextChapter
    case goToNextChapter

    case updateCurrentSentence(Sentence)
    case updateLoadingStatus(LoadingStatus)

    case selectWord(WordTimeStampData, playAudio: Bool)
    case selectChapter(Chapter)
    
    case updateSpeechSpeed(SpeechSpeed)
    case playSound(AppSound)
    
    case loadDefinitionsForChapter(Chapter, sentenceIndex: Int)
    case onLoadedDefinitions([Definition], chapter: Chapter, sentenceIndex: Int)
    case failedToLoadDefinitions
    
    case showDefinition(WordTimeStampData)
    case hideDefinition
}
