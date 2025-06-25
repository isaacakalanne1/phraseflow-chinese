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

    case loadChapters(UUID)
    case loadStories
    case onLoadedChapters([Chapter])
    case onFinishedLoadedChapters
    case failedToLoadChapters

    case deleteStory(UUID)
    case onDeletedStory(UUID)
    case failedToDeleteStory

    case saveChapter(Chapter)
    case onSavedChapter(Chapter)
    case failedToSaveChapter
    
    case setCurrentStory(UUID)
    case goToNextChapter
    case goToPreviousChapter
    case goToChapter(Int)

    case updateCurrentSentence(Sentence)
    case updateLoadingState(LoadingState)

    case selectWord(WordTimeStampData, playAudio: Bool)
    case setPlaybackTime(Double)
}
