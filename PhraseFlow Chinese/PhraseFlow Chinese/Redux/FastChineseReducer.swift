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
    case .onFetchedNewPhrases(let phrases):
        newState.sentences = newState.sentences.shuffled()
        newState.sentences.insert(contentsOf: phrases.shuffled(), at: 0)
        newState.sentenceIndex = 0
    case .onFetchedSavedPhrases(let phrases):
        newState.sentences = phrases.shuffled()
    case .submitAnswer:
        newState.answerState = newState.currentSentence?.mandarin.normalized == newState.userInput.normalized ? .correct : .wrong
    case .goToNextPhrase:
        newState.sentenceIndex = (newState.sentenceIndex + 1) % newState.sentences.count
        newState.viewState = .normal
        newState.userInput = ""
        newState.currentDefinition = nil
    case .updatePhrasesAudio(let phrases, let audioDataList):
        for (phrase, audioData) in zip(phrases, audioDataList) {
            if let index = newState.sentences.firstIndex(where: { $0.mandarin == phrase.mandarin }) {
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
        if let phrase = newState.currentSentence {
            newState.currentDefinition = .init(character: newState.characterToDefine,
                                               phrase: phrase,
                                               definition: definition)
        }
    case .fetchNewPhrases,
            .failedToFetchNewPhrases,
            .removePhrase,
            .saveSentences,
            .failedToSaveSentences,
            .fetchSavedPhrases,
            .failedToFetchSavedPhrases,
            .preloadAudio,
            .failedToPreloadAudio,
            .failedToUpdatePhraseAudio,
            .playAudio,
            .onUpdatedAudioPlayer,
            .failedToUpdateAudioPlayer,
            .failedToDefineCharacter:
        break
    }

    return newState
}
