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
    case .onFetchedAllLearningPhrases(let phrases):
        newState.allLearningPhrases = phrases
    case .goToNextPhrase:
        newState.phraseIndex = (newState.phraseIndex + 1) % newState.allLearningPhrases.count

    case .updatePhraseAudioAtIndex(let index, let audioData):
        newState.allLearningPhrases[index].audioData = audioData
    case .onTranscribedPhraseAudioAtIndex(let index, let segments):
        let startTimes: [Double] = segments.map { Double($0.startTime + 50)/1000 }
        let timestamps = startTimes.map { TimeInterval($0) }
        newState.allLearningPhrases[index].characterTimestamps = timestamps
    case .revealAnswer:
        let normalizedUserInput = newState.userInput.normalized
        let normalizedCorrectText = newState.allPhrases[newState.phraseIndex].mandarin.normalized

        newState.viewState = normalizedUserInput == normalizedCorrectText ? .revealAnswer : .normal
    case .updateAudioPlayer(let audioPlayer):
        newState.audioPlayer = audioPlayer

    case .fetchAllPhrases,
            .failedToFetchAllPhrases,
            .fetchAllLearningPhrases,
            .preloadAudio,
            .failedToPreloadAudio,
            .transcribePhraseAudioAtIndex,
            .failedToTranscribePhraseAudioAtIndex,
            .failedToUpdatePhraseAudioAtIndex,
            .playAudio,
            .onUpdatedAudioPlayer:
        break
    }

    return newState
}
