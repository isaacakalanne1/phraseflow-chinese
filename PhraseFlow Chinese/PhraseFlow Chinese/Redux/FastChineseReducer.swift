//
//  FastChineseReducer.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit

let fastChineseReducer: Reducer<FastChineseState, FastChineseAction> = { state, action in
    var newState = state

    switch action {
    case .onGeneratedNewChapter(let sentences):
        newState.sentences = sentences
        newState.sentenceIndex = 0
    case .onLoadedChapter(let chapter):
        newState.sentences = chapter.sentences
        newState.sentenceIndex = 0
    case .goToNextSentence:
        newState.sentenceIndex = (newState.sentenceIndex + 1) % newState.sentences.count
        newState.currentDefinition = nil
    case .updateSpeechSpeed(let speed):
        newState.speechSpeed = speed
    case .defineCharacter(let character):
        newState.characterToDefine = character
    case .onDefinedCharacter(let definition):
        if let sentence = newState.currentSentence {
            newState.currentDefinition = .init(character: newState.characterToDefine,
                                               sentence: sentence,
                                               definition: definition)
        }
    case .saveSentences,
            .failedToSaveSentences,
            .failedToLoadChapter,
            .playAudio,
            .failedToPlayAudio,
            .failedToDefineCharacter,
            .generateNewChapter,
            .failedToGenerateNewChapter,
            .loadChapter:
        break
    }

    return newState
}
