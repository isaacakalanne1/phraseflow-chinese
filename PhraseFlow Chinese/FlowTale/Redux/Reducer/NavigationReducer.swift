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
    case .selectChapter(var story, let chapterIndex):
        if let chapter = story.chapters[safe: chapterIndex] {
            newState.definitionState.currentDefinition = nil
            story.lastUpdated = .now
            newState.storyState.currentStory = story
            newState.settingsState.language = story.language

            if let voice = chapter.audioVoice {
                newState.settingsState.voice = voice
            }

            story.currentChapterIndex = chapterIndex
            let data = newState.storyState.currentChapter?.audio.data
            newState.audioState.audioPlayer = data?.createAVPlayer() ?? AVPlayer()
        }

    case .onSelectedChapter:
        if let language = newState.storyState.currentStory?.language {
            newState.settingsState.language = language
        }
        
    case .selectTab(let tab, _):
        newState.viewState.contentTab = tab
    }

    return newState
}
