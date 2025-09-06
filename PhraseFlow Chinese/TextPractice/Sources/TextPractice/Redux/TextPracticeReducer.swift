//
//  TextPracticeReducer.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import ReduxKit
import Foundation

@MainActor
let textPracticeReducer: Reducer<TextPracticeState, TextPracticeAction> = { state, action in
    var newState = state
    switch action {
        
    case .setChapter(let chapter):
        newState.chapter = chapter
    case .addDefinitions(let definitions):
        for definition in definitions {
            if !newState.definitions.contains(where: { $0 == definition }) {
                newState.definitions.append(definition)
            }
        }
    case .setPlaybackTime(let time):
        newState.chapter?.currentPlaybackTime = time
    case .updateCurrentSentence(let sentence):
        if var currentChapter = newState.chapter {
            currentChapter.currentSentence = sentence
            newState.chapter = currentChapter
        }
    case .playChapter:
        newState.isPlayingChapterAudio = true
    case .pauseChapter:
        newState.isPlayingChapterAudio = false
    case .refreshSettings(let settings):
        newState.settings = settings
    case .goToNextChapter,
            .prepareToPlayChapter,
            .saveAppSettings:
        break
    }
    return newState
}
