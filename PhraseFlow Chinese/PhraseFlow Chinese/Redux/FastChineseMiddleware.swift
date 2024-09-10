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
                for sheetId in state.sheetIds {
                    let phrases = try await environment.fetchAllPhrases(gid: sheetId)
                    allPhrases.append(contentsOf: phrases)
                }
            } catch {
                return .failedToFetchAllPhrases
            }
        return .onFetchedAllPhrases(allPhrases)
    case .fetchAllLearningPhrases:
        var learningPhrases: [Phrase] = []
        for category in PhraseCategory.allCases {
            let phrases = environment.fetchLearningPhrases(category: category)
            learningPhrases.append(contentsOf: phrases)
        }
        return .onFetchedAllLearningPhrases(learningPhrases)
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
                    return .updatePhraseAudioAtIndex(index: i, audioData: audioData)
                }
            }
        } catch {
            return .failedToPreloadAudio
        }
        return nil

    case .updatePhraseAudioAtIndex(let index, let audioData):
        do {
            let phrase = state.allLearningPhrases[index]
            let audioURL = try environment.saveAudioToTempFile(fileName: phrase.mandarin, data: audioData)
            return .transcribePhraseAudioAtIndex(index: index, url: audioURL)
        } catch {
            return .failedToUpdatePhraseAudioAtIndex
        }

    case .transcribePhraseAudioAtIndex(let index, let audioURL):
        do {
            let audioFrames = try await audioURL.convertAudioFileToPCMArray()
            let segments = try await environment.transcribe(audioFrames: audioFrames)
            return .onSegmentedPhraseAudioAtIndex(index: index, segments: segments)
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

    case .onFetchedAllPhrases,
            .failedToFetchAllPhrases,
            .onFetchedAllLearningPhrases,
            .revealAnswer,
            .failedToPreloadAudio,
            .failedToUpdatePhraseAudioAtIndex,
            .failedToSegmentPhraseAudioAtIndex,
            .onSegmentedPhraseAudioAtIndex,
            .updateAudioPlayer,
            .failedToUpdateAudioPlayer:
        return nil
    }
}
