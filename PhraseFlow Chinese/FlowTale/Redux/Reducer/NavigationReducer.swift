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
            newState.settingsState.voice = currentChapter.audioVoice

            let data = currentChapter.audio.data
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
