//
//  StoryAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Audio
import Study
import Foundation
import Settings
import TextGeneration

public enum StoryAction: Sendable {
    case createChapter(CreateChapterType)
    case generateText(CreateChapterType)
    case onGeneratedText(Chapter)
    case generateImage(Chapter)
    case onGeneratedImage(Chapter)
    case generateSpeech(Chapter)
    case onGeneratedSpeech(Chapter, ssmlCharacterCount: Int)
    case generateDefinitions(Chapter)
    case onGeneratedDefinitions(Chapter)
    case onCreatedChapter(Chapter)
    case failedToCreateChapter

    case loadStories
    case onLoadedStories([Chapter])
    case failedToLoadStoriesAndDefinitions

    case deleteStory(UUID)
    case onDeletedStory(UUID)
    case failedToDeleteStory

    case saveChapter(Chapter)
    case onSavedChapter(Chapter)
    case failedToSaveChapter
    
    case beginGetNextChapter
    case goToNextChapter

    case selectChapter(Chapter)
    
    case playSound(AppSound)
}
