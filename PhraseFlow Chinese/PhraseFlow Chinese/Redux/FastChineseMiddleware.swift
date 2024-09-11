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
                return .failedToFetchNewPhrases
            }
        return .onFetchedNewPhrases(newPhrases)
    case .onFetchedNewPhrases:
        return .preloadAudio
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
        return .preloadAudio
    case .submitAnswer:
        return .revealAnswer
    case .goToNextPhrase:
        return .preloadAudio
    case .preloadAudio:
        do {
            guard state.allPhrases.count > 0 else {
                return nil
            }
            for i in 0..<2 {
                if state.allPhrases.count < i {
                    return nil
                }
                let index = (state.phraseIndex + i) % state.allPhrases.count
                let phrase = state.allPhrases[index]
                if phrase.audioData == nil {
                    let audioData = try await environment.fetchSpeech(for: phrase)
                    return .updatePhraseAudio(phrase, audioData: audioData)
                }
            }
        } catch {
            return .failedToPreloadAudio
        }
        return nil

    case .updatePhraseAudio(let phrase, let audioData):
        guard phrase.category.shouldSegment else {
            return nil
        }
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
    case .playAudioFromIndex(let index):
        do {
            guard let currentPhrase = state.currentPhrase,
                  index < currentPhrase.characterTimestamps.count else {
                return .playAudio
            }

            let timestamp = currentPhrase.characterTimestamps[index]
            if let audioData = state.currentPhrase?.audioData {
                let player = try AVAudioPlayer(data: audioData)
                player.currentTime = timestamp
                return .updateAudioPlayer(player)
            }
            return nil
        } catch {
            return .failedToPlayAudioFromIndex
        }
    case .defineCharacter(let string):
        do {
            guard let mandarinPhrase = state.currentPhrase?.mandarin else {
                return nil
            }
            let response = try await environment.fetchDefinition(of: string, withinContextOf: mandarinPhrase)
            guard let definition = response.choices.first?.message.content else {
                return nil
            }
            return .onDefinedCharacter(definition)
        } catch {
            return .failedToDefineCharacter
        }
    case .updateAudioPlayer:
        return .onUpdatedAudioPlayer
    case .onUpdatedAudioPlayer:
        state.audioPlayer?.enableRate = true
        state.audioPlayer?.rate = state.speechSpeed.rate
        state.audioPlayer?.prepareToPlay()
        state.audioPlayer?.play()
        return nil

    case .failedToFetchNewPhrases,
            .failedToSaveAllPhrases,
            .onFetchedSavedPhrases,
            .failedToFetchSavedPhrases,
            .revealAnswer,
            .failedToPreloadAudio,
            .failedToUpdatePhraseAudio,
            .failedToSegmentPhraseAudioAtIndex,
            .onSegmentedPhraseAudio,
            .failedToUpdateAudioPlayer,
            .removePhrase,
            .updateSpeechSpeed,
            .failedToPlayAudioFromIndex,
            .onDefinedCharacter,
            .failedToDefineCharacter,
            .updatePracticeMode,
            .updateUserInput:
        return nil
    }
}
