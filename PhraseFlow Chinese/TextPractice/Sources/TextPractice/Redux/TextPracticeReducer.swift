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
    case .onGeneratedDefinitions(let definitions, _, _),
            .onLoadedDefinitions(let definitions):
        for definition in definitions {
            let key = DefinitionKey(word: definition.timestampData.word,
                                    sentenceId: definition.sentence.id)
            if !newState.definitions.contains(where: { $0.key == key }) {
                newState.definitions[key] = definition
            }
        }
    case .showDefinition(let word):
        // Find the definition for this word in the current sentence
        if let currentSentence = newState.chapter.currentSentence {
            let key = DefinitionKey(word: word.word, sentenceId: currentSentence.id)
            newState.selectedDefinition = newState.definitions[key]
            newState.viewState = .showDefinition
            newState.definitions[key]?.hasBeenSeen = true
            newState.definitions[key]?.creationDate = .now
        }
    case .hideDefinition:
        newState.selectedDefinition = nil
        newState.viewState = .normal
    case .selectWord(let word, _):
        newState.chapter.currentPlaybackTime = word.time
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
    case .onDefinedWord(let definition):
        newState.selectedDefinition = definition
        newState.viewState = .showDefinition
        newState.definitions[DefinitionKey(word: definition.timestampData.word, sentenceId: definition.sentence.id)]?.hasBeenSeen = true
        newState.definitions[DefinitionKey(word: definition.timestampData.word, sentenceId: definition.sentence.id)]?.creationDate = .now
    case .clearDefinition:
        newState.selectedDefinition = nil
        newState.viewState = .normal
    case .goToNextChapter,
            .prepareToPlayChapter,
            .saveAppSettings,
            .loadAppSettings,
            .failedToLoadAppSettings,
            .generateDefinitions,
            .failedToLoadDefinitions,
            .playWord,
            .defineWord,
            .failedToDefineWord,
            .loadDefinitions:
        break
    }
    return newState
}
