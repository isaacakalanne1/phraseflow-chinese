//
//  StoryReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import TextGeneration
import TextPractice

@MainActor
let storyReducer: Reducer<StoryState, StoryAction> = { state, action in
    var newState = state

    switch action {
    case .onLoadedStories(let chapters):
        let uniqueStoryIds = Set(chapters.map { $0.storyId })
        uniqueStoryIds.forEach { storyId in
            newState.storyChapters[storyId] = []
        }
        for chapter in chapters {
            newState.storyChapters[chapter.storyId]?.append(chapter)
        }
        
        // Sort chapters by last updated for each story
        for storyId in newState.storyChapters.keys {
            newState.storyChapters[storyId]?.sort { $0.lastUpdated < $1.lastUpdated }
        }

        // Set current story if none is set
        if newState.currentChapter == nil {
            if let firstStory = newState.allStories.first {
                newState.currentChapter = newState.storyChapters[firstStory.storyId]?.last
            }
        }

    case .onCreatedChapter(var chapter):
        newState.isWritingChapter = false
        chapter.currentPlaybackTime = chapter.sentences.first?.timestamps.first?.time ?? 0.1

        // Add chapter to story
        if newState.storyChapters[chapter.storyId] == nil {
            newState.storyChapters[chapter.storyId] = []
        }
        newState.storyChapters[chapter.storyId]?.append(chapter)
        
        // Set as current story
        newState.currentChapter = chapter
        newState.currentChapter?.currentSentence = chapter.sentences.first
        
    case .onDeletedStory(let storyId):
        newState.storyChapters.removeValue(forKey: storyId)
        if newState.currentChapter?.storyId == storyId {
            if let firstStory = newState.allStories.first {
                newState.currentChapter = newState.storyChapters[firstStory.storyId]?.first
            } else {
                newState.currentChapter = nil
            }
        }
        
    case .onSavedChapter(let chapter):
        if let storyChapters = newState.storyChapters[chapter.storyId],
           let index = storyChapters.firstIndex(where: { $0.id == chapter.id }) {
            newState.storyChapters[chapter.storyId]?[index] = chapter
        }
        
    case .goToNextChapter:
        guard let currentChapter = newState.currentChapter,
              let storyChapters = newState.storyChapters[currentChapter.storyId],
              let currentIndex = storyChapters.firstIndex(where: { $0.id == currentChapter.id }),
              !newState.isLastChapter else { break }
        let nextIndex = currentIndex + 1
        
        newState.currentChapter = storyChapters[nextIndex]
        newState.storyChapters[currentChapter.storyId]?[nextIndex] = storyChapters[nextIndex]
        
    case .selectChapter(let chapter):
        newState.currentChapter = chapter
        
    case .createChapter:
        newState.isWritingChapter = true
        
    case .generateText:
        newState.isWritingChapter = true
        
    case .onGeneratedText,
         .generateImage,
         .onGeneratedImage,
         .generateSpeech,
         .onGeneratedSpeech,
         .generateDefinitions,
         .onGeneratedDefinitions:
        break
        
    case .failedToCreateChapter:
        newState.isWritingChapter = false
    case .refreshAppSettings(let settings):
        newState.settings = settings
    case .loadStories,
         .failedToLoadStoriesAndDefinitions,
         .deleteStory,
         .failedToDeleteStory,
         .saveChapter,
         .failedToSaveChapter,
         .playSound,
         .beginGetNextChapter:
        break
    }

    return newState
}
