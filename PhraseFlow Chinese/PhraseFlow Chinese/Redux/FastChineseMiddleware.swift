//
//  FastChineseMiddleware.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit

typealias FastChineseMiddlewareType = Middleware<FastChineseState, FastChineseAction, FastChineseEnvironmentProtocol>
let fastChineseMiddleware: FastChineseMiddlewareType = { state, action, environment in
    switch action {
    case .fetchAllPhrases:
        var allPhrases: [Phrase] = []
            do {
                for category in PhraseCategory.allCases {
                    let phrases = try await environment.fetchPhrases(category: category)
                    allPhrases.append(contentsOf: phrases)
                }
            } catch {
                return .failedToFetchAllPhrases
            }
        return .onFetchedAllPhrases(allPhrases)
    case .onFetchedAllPhrases:
        return .saveAllPhrases
    case .fetchSavedPhrases:
        
    case .saveAllPhrases:
        do {
            try environment.saveAllPhrases(state.allPhrases)
        } catch {
            return .failedToSaveAllPhrases
        }
        return nil
    case .clearAllLearningPhrases:
        for category in PhraseCategory.allCases {
            environment.clearLearningPhrases(category: category)
        }
        return nil

    case .goToNextPhrase:
        return .preloadAudio
    case .preloadAudio:
        do {
            for i in 0..<1 {
                let index = (state.phraseIndex + i) % state.allLearningPhrases.count
                let phrase = state.allLearningPhrases[index]
                if phrase.audioData == nil {
                    let audioData = try await environment.fetchSpeech(for: phrase)
                    let audioURL = try environment.saveAudioToTempFile(fileName: phrase.mandarin, data: audioData)
                    let audioFrames = try await audioURL.convertAudioFileToPCMArray()
                    let segments = try await environment.transcribe(audioFrames: audioFrames)
                    let startTimes: [Double] = segments.map { Double($0.startTime + 50)/1000 }
                    let segmentTimes = startTimes.map { TimeInterval($0) }
                    return .updatePhraseAudio(phrase, audioData: audioData)
                }
            }
        } catch {
            return .failedToPreloadAudio
        }
        return nil

    case .updatePhraseAudio(let phrase, let audioData):
        do {
            let audioURL = try environment.saveAudioToTempFile(fileName: phrase.mandarin, data: audioData)
            return .segmentPhraseAudio(phrase, url: audioURL)
        } catch {
            return .failedToUpdatePhraseAudio
        }

    case .segmentPhraseAudio(let phrase, let audioURL):
        do {
            let audioFrames = try await audioURL.convertAudioFileToPCMArray()
            let segments = try await environment.transcribe(audioFrames: audioFrames)
            return .onSegmentedPhraseAudio(phrase, segments: segments)
        } catch {
            return .failedToSegmentPhraseAudioAtIndex
        }

    case .playAudio:
        do {
            if let audioData = state.currentPhrase?.audioData {
                let audioPlayer = try AVAudioPlayer(data: audioData)
                return .updateAudioPlayer(audioPlayer)
            }
            return nil
        } catch {
            return .failedToUpdateAudioPlayer
        }

    case .onUpdatedAudioPlayer:
        state.audioPlayer?.enableRate = true
        state.audioPlayer?.rate = state.speechSpeed.rate
        state.audioPlayer?.prepareToPlay()
        state.audioPlayer?.play()
        return nil

    case .failedToFetchAllPhrases,
            .failedToSaveAllPhrases,
            .revealAnswer,
            .failedToPreloadAudio,
            .failedToUpdatePhraseAudio,
            .failedToSegmentPhraseAudioAtIndex,
            .onSegmentedPhraseAudio,
            .updateAudioPlayer,
            .failedToUpdateAudioPlayer,
            .updatePhraseToLearning,
            .removePhraseFromLearning:
        return nil
    }
}
