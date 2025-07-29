//
//  StoryReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import TextGeneration

public let storyReducer: @Sendable (StoryState, StoryAction) -> StoryState = { state, action in
    var newState = state

    switch action {
    case .onLoadedStoriesAndDefitions(let chapters, _):
        for chapter in chapters {
            if newState.storyChapters[chapter.storyId] == nil {
                newState.storyChapters[chapter.storyId] = []
            }
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
        
    case .setPlaybackTime(let time):
        if var currentChapter = newState.currentChapter {
            currentChapter.currentPlaybackTime = time
            newState.currentChapter = currentChapter
            if let storyId = currentChapter.storyId as UUID?,
               let chapters = newState.storyChapters[storyId],
               let index = chapters.firstIndex(where: { $0.id == currentChapter.id }) {
                newState.storyChapters[storyId]?[index] = currentChapter
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
              let chapters = newState.storyChapters[currentChapter.storyId],
              let currentIndex = chapters.firstIndex(where: { $0.id == currentChapter.id }),
              currentIndex < chapters.count - 1 else { break }
        
        var nextChapter = chapters[currentIndex + 1]
        let sentence = newState.currentChapter?.currentSentence
        nextChapter.currentPlaybackTime = sentence?.timestamps.first?.time ?? 0.1
        newState.currentChapter = nextChapter
        newState.storyChapters[currentChapter.storyId]?[currentIndex + 1] = nextChapter
        
    case .updateCurrentSentence(let sentence):
        if var currentChapter = newState.currentChapter {
            currentChapter.currentSentence = sentence
            newState.currentChapter = currentChapter
            if let chapters = newState.storyChapters[currentChapter.storyId],
               let index = chapters.firstIndex(where: { $0.id == currentChapter.id }) {
                newState.storyChapters[currentChapter.storyId]?[index] = currentChapter
            }
        }
        
    case .selectWord(let word, _):
        if var currentChapter = newState.currentChapter {
            currentChapter.currentPlaybackTime = word.time
            newState.currentChapter = currentChapter
            if let storyId = currentChapter.storyId as UUID?,
               let chapters = newState.storyChapters[storyId],
               let index = chapters.firstIndex(where: { $0.id == currentChapter.id }) {
                newState.storyChapters[storyId]?[index] = currentChapter
            }
        }
        
    case .selectChapter(let storyId):
        if let chapters = newState.storyChapters[storyId], !chapters.isEmpty {
            let selectedChapter = chapters.last ?? chapters[0]
            newState.currentChapter = selectedChapter
        }
        
    case .createChapter:
        newState.isWritingChapter = true
        
    case .failedToCreateChapter:
        newState.isWritingChapter = false
        
    case .loadStoriesAndDefinitions,
         .failedToLoadStoriesAndDefinitions,
         .deleteStory,
         .failedToDeleteStory,
         .saveChapter,
         .failedToSaveChapter,
         .updateLoadingStatus,
         .playWord,
         .playChapter,
         .pauseChapter,
         .updateSpeechSpeed:
        break
    }

    return newState
}
