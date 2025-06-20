//
//  NavigationReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import AVKit

let navigationReducer: Reducer<FlowTaleState, NavigationAction> = { state, action in
    var newState = state

    switch action {
    case .selectChapter(let storyId, let chapterIndex):
        newState.storyState.currentStoryId = storyId
        newState.storyState.currentChapterIndex = chapterIndex
        
        if let currentChapter = newState.storyState.currentChapter {
            newState.definitionState.currentDefinition = nil
            newState.settingsState.language = currentChapter.language

            if let voice = currentChapter.audioVoice {
                newState.settingsState.voice = voice
            }

            let data = currentChapter.audio.data
            let player = data.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()

            newState.viewState.contentTab = .reader
        }
        
    case .selectChapterLegacy(var story, let chapterIndex):
        if let chapter = story.chapters[safe: chapterIndex] {
            newState.definitionState.currentDefinition = nil
            story.lastUpdated = .now
            newState.settingsState.language = story.language

            if let voice = chapter.audioVoice {
                newState.settingsState.voice = voice
            }

            let data = chapter.audio.data
            newState.audioState.audioPlayer = data.createAVPlayer() ?? AVPlayer()
            
            newState.viewState.contentTab = .reader
        }

    case .onSelectedChapter:
        if let language = newState.storyState.currentChapter?.language {
            newState.settingsState.language = language
        }
        
    case .selectTab(let tab, _):
        newState.viewState.contentTab = tab
    }

    return newState
}
