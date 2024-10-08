//
//  FastChineseReducer.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit

let fastChineseReducer: Reducer<FastChineseState, FastChineseAction> = { state, action in
    var newState = state

    switch action {
    case .updateUserInput(let string):
        newState.userInput = string
    case .onGeneratedNewChapter(let sentences):
        newState.sentences = sentences
        newState.sentenceIndex = 0
    case .onLoadedChapter(let sentences):
        newState.sentences = sentences
        newState.sentenceIndex = 0
    case .submitAnswer:
        newState.answerState = newState.currentSentence?.mandarin.normalized == newState.userInput.normalized ? .correct : .wrong
    case .goToNextPhrase:
        newState.sentenceIndex = (newState.sentenceIndex + 1) % newState.sentences.count
        newState.viewState = .normal
        newState.userInput = ""
        newState.currentDefinition = nil
    case .updateSentencesAudio(let sentences, let audioDataList):
        for (sentence, audioData) in zip(sentences, audioDataList) {
            if let index = newState.sentences.firstIndex(where: { $0.mandarin == sentence.mandarin }) {
                newState.sentences[index].audioData = audioData
            }
        }
    case .revealAnswer:
        newState.viewState = .revealAnswer
    case .updateAudioPlayer(let audioPlayer):
        newState.audioPlayer = audioPlayer
    case .updateSpeechSpeed(let speed):
        newState.speechSpeed = speed
    case .updatePracticeMode(let mode):
        newState.practiceMode = mode
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
            .preloadAudio,
            .failedToPreloadAudio,
            .failedToUpdateSentencesAudio,
            .playAudio,
            .onUpdatedAudioPlayer,
            .failedToUpdateAudioPlayer,
            .failedToDefineCharacter,
            .generateNewChapter,
            .failedToGenerateNewChapter,
            .loadChapter:
        break
    }

    return newState
}
