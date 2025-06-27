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
        
        if let chapters = newState.storyState.storyChapters[storyId],
           chapterIndex >= 0 && chapterIndex < chapters.count {
            let selectedChapter = chapters[chapterIndex]
            newState.storyState.currentChapter = selectedChapter
            newState.definitionState.currentDefinition = nil
            newState.settingsState.language = selectedChapter.language
            newState.settingsState.voice = selectedChapter.audioVoice

            let data = selectedChapter.audio.data
            let player = data.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
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
