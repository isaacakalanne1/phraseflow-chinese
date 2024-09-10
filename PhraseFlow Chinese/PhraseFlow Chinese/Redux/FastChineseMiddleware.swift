//
//  FastChineseMiddleware.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit

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
                    audioURL.convertAudioFileToPCMArray { result in
                        guard let audioFrames = try? result.get() else {
                            return
                        }
                    }
                }
            }
        } catch {
            return .failedToPreloadAudio
        }

    case .onFetchedAllPhrases,
            .failedToFetchAllPhrases,
            .onFetchedAllLearningPhrases:
        return nil
    }
}
