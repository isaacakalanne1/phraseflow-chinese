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
    case .onFetchedNewPhrases(let phrases):
        newState.allPhrases.insert(contentsOf: phrases, at: 0)
    case .onFetchedSavedPhrases(let phrases):
        newState.allPhrases = phrases
    case .clearAllLearningPhrases:
        let phrases: [Phrase] = newState.allPhrases.map({ .init(mandarin: $0.mandarin,
                                                                pinyin: $0.pinyin,
                                                                english: $0.english,
                                                                category: $0.category,
                                                                isLearning: false) })
        newState.allPhrases = phrases
    case .submitAnswer(let answer):
        newState.userInput = answer.normalized
        newState.answerState = newState.currentPhrase?.mandarin.normalized == newState.userInput ? .correct : .wrong
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
        newState.viewState = .revealAnswer
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
    case .updateSpeechSpeed(let speed):
        newState.speechSpeed = speed
    case .updatePracticeMode(let mode):
        newState.practiceMode = mode
    case .fetchNewPhrases,
            .failedToFetchAllPhrases,
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
            .failedToUpdateAudioPlayer:
        break
    }

    return newState
}
