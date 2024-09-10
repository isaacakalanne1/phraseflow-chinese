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
    case .onFetchedAllPhrases(let phrases):
        newState.allPhrases = phrases
    case .goToNextPhrase:
        newState.phraseIndex = (newState.phraseIndex + 1) % newState.allLearningPhrases.count

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
        let normalizedUserInput = newState.userInput.normalized
        let normalizedCorrectText = newState.allPhrases[newState.phraseIndex].mandarin.normalized

        newState.viewState = normalizedUserInput == normalizedCorrectText ? .revealAnswer : .normal
    case .updateAudioPlayer(let audioPlayer):
        newState.audioPlayer = audioPlayer
    case .updatePhraseToLearning(let phrase):
        if let index = newState.allPhrases.firstIndex(where: { $0.mandarin == phrase.mandarin }) {
            newState.allPhrases[index].isLearning = true
        }
    case .removePhraseFromLearning(let phrase):
        if let index = newState.allPhrases.firstIndex(where: { $0.mandarin == phrase.mandarin }) {
            newState.allPhrases[index].isLearning = false
        }
    case .fetchAllPhrases,
            .failedToFetchAllPhrases,
            .saveAllPhrases,
            .failedToSaveAllPhrases,
            .clearAllLearningPhrases,
            .preloadAudio,
            .failedToPreloadAudio,
            .segmentPhraseAudio,
            .failedToSegmentPhraseAudioAtIndex,
            .failedToUpdatePhraseAudio,
            .playAudio,
            .onUpdatedAudioPlayer,
            .failedToUpdateAudioPlayer:
        break
    }

    return newState
}
