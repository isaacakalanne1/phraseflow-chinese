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
    case .onLoadedChapters(let chapters, let isAppLaunch):
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
        if newState.storyState.currentStoryId == nil {
            newState.storyState.currentStoryId = newState.storyState.allStories.first?.storyId
            newState.storyState.currentChapterIndex = 0
        }
        
        // Set up audio player for current chapter
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
            if let latestChapter = newState.storyState.latestChapter(for: storyId) {
                newState.settingsState.voice = latestChapter.audioVoice
                newState.viewState.shouldShowImageSpinner = latestChapter.imageData == nil
            }
        }
        newState.viewState.loadingState = .writing
        
    case .onCreatedChapter(var chapter):
        newState.definitionState.currentDefinition = nil

        chapter.currentPlaybackTime = 0
        
        // Add chapter to story
        if newState.storyState.storyChapters[chapter.storyId] == nil {
            newState.storyState.storyChapters[chapter.storyId] = []
        }
        newState.storyState.storyChapters[chapter.storyId]?.append(chapter)
        
        // Set as current story
        newState.storyState.currentStoryId = chapter.storyId
        newState.storyState.currentChapterIndex = (newState.storyState.storyChapters[chapter.storyId]?.count ?? 1) - 1
        
        newState.storyState.currentSentence = chapter.sentences.first
        newState.viewState.contentTab = .reader

        let player = chapter.audio.data.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()

        newState.snackBarState.type = .chapterReady
        newState.snackBarState.isShowing = true
        
    case .onDeletedStory(let storyId):
        newState.storyState.storyChapters.removeValue(forKey: storyId)
        if newState.storyState.currentStoryId == storyId {
            newState.storyState.currentStoryId = newState.storyState.allStories.first?.storyId
            newState.storyState.currentChapterIndex = 0
            newState.viewState.contentTab = .storyList
        }
        
    case .onSavedChapter(let chapter):
        if let storyChapters = newState.storyState.storyChapters[chapter.storyId],
           let index = storyChapters.firstIndex(where: { $0.id == chapter.id }) {
            newState.storyState.storyChapters[chapter.storyId]?[index] = chapter
        }
        
    case .setCurrentStory(let storyId):
        newState.storyState.currentStoryId = storyId
        newState.storyState.currentChapterIndex = 0
        let data = newState.storyState.currentChapter?.audio.data
        let player = data?.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        
    case .goToNextChapter:
        guard let currentStoryId = newState.storyState.currentStoryId,
              let chapters = newState.storyState.storyChapters[currentStoryId] else { break }
        
        if newState.storyState.currentChapterIndex < chapters.count - 1 {
            newState.storyState.currentChapterIndex += 1
            let data = newState.storyState.currentChapter?.audio.data
            let player = data?.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
            
            let sentence = newState.storyState.currentSentence
            newState.storyState.storyChapters[currentStoryId]?[newState.storyState.currentChapterIndex].currentPlaybackTime = sentence?.timestamps.first?.time ?? 0.1
        }
        
    case .goToPreviousChapter:
        if newState.storyState.currentChapterIndex > 0 {
            newState.storyState.currentChapterIndex -= 1
            let data = newState.storyState.currentChapter?.audio.data
            let player = data?.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }
        
    case .goToChapter(let index):
        guard let currentStoryId = newState.storyState.currentStoryId,
              let chapters = newState.storyState.storyChapters[currentStoryId],
              index >= 0 && index < chapters.count else { break }
        
        newState.storyState.currentChapterIndex = index
        let data = newState.storyState.currentChapter?.audio.data
        let player = data?.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        
    case .updatePlaybackTime(let time):
        guard let currentStoryId = newState.storyState.currentStoryId else { break }
        newState.storyState.storyChapters[currentStoryId]?[newState.storyState.currentChapterIndex].currentPlaybackTime = time
        
    case .failedToLoadChapters:
        newState.viewState.isInitialisingApp = false
    case .failedToCreateChapter:
        newState.viewState.isWritingChapter = false
    case .updateCurrentSentence(let sentence):
        newState.storyState.currentSentence = sentence
    case .updateAutoScrollEnabled(let isEnabled):
        newState.viewState.isAutoscrollEnabled = isEnabled
    case .updateLoadingState(let loadingState):
        newState.viewState.loadingState = loadingState
    case .loadChapters,
            .loadStories,
            .deleteStory,
            .saveChapter,
            .onFinishedLoadedChapters,
            .failedToDeleteStory,
            .failedToSaveChapter:
        break
    }

    return newState
}
