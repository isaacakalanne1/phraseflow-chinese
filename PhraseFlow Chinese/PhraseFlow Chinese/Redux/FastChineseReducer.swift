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
        newState.allPhrases.insert(contentsOf: phrases, at: 0)
    case .onFetchedSavedPhrases(let phrases):
        newState.allPhrases = phrases
        newState.allPhrases = phrases
    case .submitAnswer:
        newState.answerState = newState.currentPhrase?.mandarin.normalized == newState.userInput.normalized ? .correct : .wrong
    case .goToNextPhrase:
        newState.phraseIndex = (newState.phraseIndex + 1) % newState.allPhrases.count
        newState.viewState = .normal

    case .updatePhraseAudio(let phrase, let audioData):
        if let index = newState.allPhrases.firstIndex(where: { $0.mandarin == phrase.mandarin }) {
            newState.allPhrases[index].audioData = audioData
        }
    case .onSegmentedPhraseAudio(let phrase, let segments):
        if let index = newState.allPhrases.firstIndex(where: { $0.mandarin == phrase.mandarin }) {
            let startTimes: [Double] = segments.map { Double($0.startTime + 50)/1000 }
            let timestamps = startTimes.map { TimeInterval($0) }
            newState.allPhrases[index].characterTimestamps = timestamps
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
        if let phrase = newState.currentPhrase {
            newState.currentDefinition = .init(character: newState.characterToDefine,
                                               phrase: phrase,
                                               definition: definition)
        }
    case .fetchNewPhrases,
            .failedToFetchNewPhrases,
            .removePhrase,
            .saveAllPhrases,
            .failedToSaveAllPhrases,
            .fetchSavedPhrases,
            .failedToFetchSavedPhrases,
            .preloadAudio,
            .failedToPreloadAudio,
            .segmentPhraseAudio,
            .failedToSegmentPhraseAudioAtIndex,
            .failedToUpdatePhraseAudio,
            .playAudio,
            .onUpdatedAudioPlayer,
            .failedToUpdateAudioPlayer,
            .playAudioFromIndex,
            .failedToPlayAudioFromIndex,
            .failedToDefineCharacter:
        break
    }

    return newState
}
