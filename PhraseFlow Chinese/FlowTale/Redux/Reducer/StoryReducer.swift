//
//  StoryReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import AVKit

let storyReducer: Reducer<FlowTaleState, StoryAction> = { state, action in
    var newState = state

    switch action {
    case .onLoadedStoriesAndDefitions(let chapters, let definitions):
        newState.definitionState.definitions = definitions
        for chapter in chapters {
            if newState.storyState.storyChapters[chapter.storyId] == nil {
                newState.storyState.storyChapters[chapter.storyId] = []
            }
            newState.storyState.storyChapters[chapter.storyId]?.append(chapter)
        }
        
        // Sort chapters by last updated for each story
        for storyId in newState.storyState.storyChapters.keys {
            newState.storyState.storyChapters[storyId]?.sort { $0.lastUpdated < $1.lastUpdated }
        }
        
        newState.viewState.isInitialisingApp = false

        // Set current story if none is set
        if newState.storyState.currentChapter == nil {
            if let firstStory = newState.storyState.allStories.first {
                newState.storyState.currentChapter = newState.storyState.storyChapters[firstStory.storyId]?.last
            }
        }
        
        if let currentChapter = newState.storyState.currentChapter {
            let player = currentChapter.audio.data.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }
        
    case .createChapter(let type):
        newState.viewState.isWritingChapter = true

        switch type {
        case .newStory:
            newState.viewState.shouldShowImageSpinner = true
        case .existingStory(let storyId):
            if let firstChapter = newState.storyState.firstChapter(for: storyId) {
                newState.settingsState.voice = firstChapter.audioVoice
                newState.viewState.shouldShowImageSpinner = firstChapter.imageData == nil
            }
        }
        newState.viewState.loadingState = .writing

    case .setPlaybackTime(let time):
        if var currentChapter = newState.storyState.currentChapter {
            currentChapter.currentPlaybackTime = time
            newState.storyState.currentChapter = currentChapter
            if let storyId = currentChapter.storyId as UUID?,
               let chapters = newState.storyState.storyChapters[storyId],
               let index = chapters.firstIndex(where: { $0.id == currentChapter.id }) {
                newState.storyState.storyChapters[storyId]?[index] = currentChapter
            }
        }

    case .onCreatedChapter(var chapter):
        newState.definitionState.currentDefinition = nil

        chapter.currentPlaybackTime = chapter.sentences.first?.timestamps.first?.time ?? 0.1

        // Add chapter to story
        if newState.storyState.storyChapters[chapter.storyId] == nil {
            newState.storyState.storyChapters[chapter.storyId] = []
        }
        newState.storyState.storyChapters[chapter.storyId]?.append(chapter)
        
        // Set as current story
        newState.storyState.currentChapter = chapter
        
        newState.storyState.currentChapter?.currentSentence = chapter.sentences.first
        newState.viewState.contentTab = .reader

        let player = chapter.audio.data.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        
    case .onDeletedStory(let storyId):
        newState.storyState.storyChapters.removeValue(forKey: storyId)
        if newState.storyState.currentChapter?.storyId == storyId {
            if let firstStory = newState.storyState.allStories.first {
                newState.storyState.currentChapter = newState.storyState.storyChapters[firstStory.storyId]?.first
            } else {
                newState.storyState.currentChapter = nil
            }
            newState.viewState.contentTab = .storyList
        }
        
    case .onSavedChapter(let chapter):
        if let storyChapters = newState.storyState.storyChapters[chapter.storyId],
           let index = storyChapters.firstIndex(where: { $0.id == chapter.id }) {
            newState.storyState.storyChapters[chapter.storyId]?[index] = chapter
        }
        
    case .setCurrentStory(let storyId):
        newState.storyState.currentChapter = newState.storyState.storyChapters[storyId]?.first
        let data = newState.storyState.currentChapter?.audio.data
        let player = data?.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        
    case .goToNextChapter:
        guard let currentChapter = newState.storyState.currentChapter,
              let chapters = newState.storyState.storyChapters[currentChapter.storyId],
              let currentIndex = chapters.firstIndex(where: { $0.id == currentChapter.id }),
              currentIndex < chapters.count - 1 else { break }
        
        var nextChapter = chapters[currentIndex + 1]
        let sentence = newState.storyState.currentChapter?.currentSentence
        nextChapter.currentPlaybackTime = sentence?.timestamps.first?.time ?? 0.1
        newState.storyState.currentChapter = nextChapter
        newState.storyState.storyChapters[currentChapter.storyId]?[currentIndex + 1] = nextChapter
        
        let data = nextChapter.audio.data
        let player = data.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        
    case .goToPreviousChapter:
        guard let currentChapter = newState.storyState.currentChapter,
              let chapters = newState.storyState.storyChapters[currentChapter.storyId],
              let currentIndex = chapters.firstIndex(where: { $0.id == currentChapter.id }),
              currentIndex > 0 else { break }
        
        let previousChapter = chapters[currentIndex - 1]
        newState.storyState.currentChapter = previousChapter
        
        let data = previousChapter.audio.data
        let player = data.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        
    case .goToChapter(let index):
        guard let currentChapter = newState.storyState.currentChapter,
              let chapters = newState.storyState.storyChapters[currentChapter.storyId],
              index >= 0 && index < chapters.count else { break }
        
        let targetChapter = chapters[index]
        newState.storyState.currentChapter = targetChapter
        
        let data = targetChapter.audio.data
        let player = data.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        
    case .failedToLoadStoriesAndDefinitions:
        newState.viewState.isInitialisingApp = false
    case .failedToCreateChapter:
        newState.viewState.isWritingChapter = false
    case .updateCurrentSentence(let sentence):
        if var currentChapter = newState.storyState.currentChapter {
            currentChapter.currentSentence = sentence
            newState.storyState.currentChapter = currentChapter
            if let chapters = newState.storyState.storyChapters[currentChapter.storyId],
               let index = chapters.firstIndex(where: { $0.id == currentChapter.id }) {
                newState.storyState.storyChapters[currentChapter.storyId]?[index] = currentChapter
            }
        }
    case .updateLoadingState(let loadingState):
        newState.viewState.loadingState = loadingState
    case .selectWord(let word, _):
        if var currentChapter = newState.storyState.currentChapter {
            currentChapter.currentPlaybackTime = word.time
            newState.storyState.currentChapter = currentChapter
            if let storyId = currentChapter.storyId as UUID?,
               let chapters = newState.storyState.storyChapters[storyId],
               let index = chapters.firstIndex(where: { $0.id == currentChapter.id }) {
                newState.storyState.storyChapters[storyId]?[index] = currentChapter
            }
        }
    case .loadStoriesAndDefinitions,
            .deleteStory,
            .saveChapter,
            .failedToDeleteStory,
            .failedToSaveChapter:
        break
    }

    return newState
}
