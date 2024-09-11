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
    case .fetchNewPhrases(let category):
        var newPhrases: [Phrase] = []
            do {
                newPhrases = try await environment.fetchPhrases(category: category)
            } catch {
                return .failedToFetchAllPhrases
            }
        return .onFetchedNewPhrases(newPhrases)
    case .onFetchedNewPhrases:
        return .saveAllPhrases
    case .fetchSavedPhrases:
        do {
            let phrases = try environment.fetchSavedPhrases()
            return .onFetchedSavedPhrases(phrases)
        } catch {
            return .failedToFetchSavedPhrases
        }
    case .saveAllPhrases:
        do {
            try environment.saveAllPhrases(state.allPhrases)
        } catch {
            return .failedToSaveAllPhrases
        }
        return nil
    case .clearAllLearningPhrases:
        return .saveAllPhrases
    case .submitAnswer:
        return .revealAnswer
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
    case .updateAudioPlayer:
        return .onUpdatedAudioPlayer
    case .onUpdatedAudioPlayer:
        state.audioPlayer?.enableRate = true
        state.audioPlayer?.rate = state.speechSpeed.rate
        state.audioPlayer?.prepareToPlay()
        state.audioPlayer?.play()
        return nil

    case .failedToFetchAllPhrases,
            .failedToSaveAllPhrases,
            .onFetchedSavedPhrases,
            .failedToFetchSavedPhrases,
            .revealAnswer,
            .failedToPreloadAudio,
            .failedToUpdatePhraseAudio,
            .failedToSegmentPhraseAudioAtIndex,
            .onSegmentedPhraseAudio,
            .failedToUpdateAudioPlayer,
            .updatePhraseToLearning,
            .removePhraseFromLearning:
        return nil
    }
}
