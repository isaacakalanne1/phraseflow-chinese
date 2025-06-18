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
    case .onLoadedStories(let stories, let isAppLaunch):
        newState.storyState.savedStories = stories
        newState.viewState.isInitialisingApp = false
        if newState.storyState.currentStory == nil ||
           !stories.contains(where: { $0.id == newState.storyState.currentStory?.id }) {
            newState.storyState.currentStory = stories.first
            let data = newState.storyState.currentChapter?.audio.data
            let player = data?.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }
        
    case .onLoadedChapters(let story, let chapters, _):
        if let index = newState.storyState.savedStories.firstIndex(where: { $0.id == story.id }) {
            var updatedStory = newState.storyState.savedStories[index]
            updatedStory.chapters = chapters
            newState.storyState.savedStories[index] = updatedStory
        }
        if newState.storyState.currentStory?.id == story.id {
            newState.storyState.currentStory?.chapters = chapters
            let data = newState.storyState.currentChapter?.audio.data
            let player = data?.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }
        newState.storyState.currentSentence = newState.storyState.currentChapter?.sentences.last(where: { $0.timestamps.contains(where: { story.currentPlaybackTime >= $0.time }) })
        
    case .createChapter(let type):
        newState.viewState.isWritingChapter = true

        switch type {
        case .newStory:
            newState.viewState.shouldShowImageSpinner = true
        case .existingStory(let story):
            newState.settingsState.voice = story.chapters.last?.audioVoice ?? newState.settingsState.voice
            newState.viewState.shouldShowImageSpinner = story.imageData == nil
        }
        newState.viewState.loadingState = .writing
        
    case .onCreatedChapter(var story):
        newState.definitionState.currentDefinition = nil

        story.currentPlaybackTime = 0
        story.currentChapterIndex = story.chapters.count - 1

        newState.storyState.currentStory = story
        newState.storyState.currentSentence = story.chapters.last?.sentences.first
        newState.viewState.contentTab = .reader

        let player = story.chapters.last?.audio.data.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()

        newState.snackBarState.type = .chapterReady
        newState.snackBarState.isShowing = true
        
    case .onDeletedStory(let storyId):
        if newState.storyState.currentStory?.id == storyId {
            newState.storyState.currentStory = nil
            newState.viewState.contentTab = .storyList
        }
        
    case .goToNextChapter:
        var newStory = newState.storyState.currentStory
        newStory?.currentChapterIndex += 1
        newState.storyState.currentStory = newStory
        let data = newState.storyState.currentChapter?.audio.data
        let player = data?.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        let sentence = newState.storyState.currentSentence
        newState.storyState.currentStory?.currentPlaybackTime = sentence?.timestamps.first?.time ?? 0.1
    case .failedToLoadStories:
        newState.viewState.isInitialisingApp = false
    case .failedToCreateChapter:
        newState.viewState.isWritingChapter = false
    case .loadStories,
         .onFinishedLoadedStories,
         .failedToLoadChapters,
         .loadChapters,
         .deleteStory,
         .failedToDeleteStory,
         .saveStoryAndSettings:
        break
    }

    return newState
}
