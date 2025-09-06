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
            let key = DefinitionKey(word: definition.timestampData.word,
                                    sentenceId: definition.sentence.id)
            if !newState.definitions.contains(where: { $0.key == key }) {
                newState.definitions[key] = definition
            }
        }
    case .setPlaybackTime(let time):
        newState.chapter.currentPlaybackTime = time
    case .updateCurrentSentence(let sentence):
        newState.chapter.currentSentence = sentence
    case .playChapter:
        newState.isPlayingChapterAudio = true
    case .pauseChapter:
        newState.isPlayingChapterAudio = false
    case .refreshSettings(let settings):
        newState.settings = settings
    case .goToNextChapter,
            .prepareToPlayChapter,
            .saveAppSettings,
            .loadAppSettings,
            .failedToLoadAppSettings:
        break
    }
    return newState
}
