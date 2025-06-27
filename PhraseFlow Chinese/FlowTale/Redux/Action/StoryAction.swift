//
//  StoryAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum StoryAction {
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
    
    case goToNextChapter

    case updateCurrentSentence(Sentence)
    case updateLoadingState(LoadingState)

    case selectWord(WordTimeStampData, playAudio: Bool)
    case setPlaybackTime(Double)
}
