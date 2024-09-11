//
//  FastChineseMiddleware.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit
import SwiftWhisper

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
    case .onFetchedSavedPhrases:
        return .preloadAudio
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
            var phrases: [Phrase] = []
            var audioDataList: [Data] = []
            for i in 0..<2 {
                let index = (state.phraseIndex + i) % state.allPhrases.count
                let phrase = state.allPhrases[index]
                if phrase.audioData == nil {
                    let audioData = try await environment.fetchSpeech(for: phrase)
                    phrases.append(phrase)
                    audioDataList.append(audioData)
                }
            }
            return .updatePhrasesAudio(phrases, audioDataList: audioDataList)
        } catch {
            return .failedToPreloadAudio
        }

    case .updatePhrasesAudio(let phrases, let audioDataList):
//        guard phrases.contains(where: { $0.category.shouldSegment }) else {
//            return nil
//        }
        do {
            var audioUrlList: [URL] = []
            for (phrase, audioData) in zip(phrases, audioDataList) {
                let audioURL = try environment.saveAudioToTempFile(fileName: phrase.mandarin, data: audioData)
                audioUrlList.append(audioURL)
            }
            return .segmentPhrasesAudio(phrases, urlList: audioUrlList)
        } catch {
            return .failedToUpdatePhraseAudio
        }

    case .segmentPhrasesAudio(let phrases, let audioUrlList):
        var segmentsList: [[Segment]] = []
        do {
            for (phrase, audioUrl) in zip(phrases, audioUrlList) {
                let audioFrames = try await audioUrl.convertAudioFileToPCMArray()
                var segments = try await environment.transcribe(audioFrames: audioFrames)
                if let firstSegment = segments.first,
                   firstSegment.text.isEmpty {
                    segments.removeFirst()
                }
                segmentsList.append(segments)
            }
            return .onSegmentedPhrasesAudio(phrases, segmentsList: segmentsList)
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
            guard let segment = state.currentPhrase?.segment(for: index) else {
                return .playAudio
            }

            let startTimeDouble = Double(segment.startTime + 50)/1000
            let startTime = TimeInterval(startTimeDouble)

            if let audioData = state.currentPhrase?.audioData {
                let player = try AVAudioPlayer(data: audioData)
                player.currentTime = startTime
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
            .failedToFetchSavedPhrases,
            .revealAnswer,
            .failedToPreloadAudio,
            .failedToUpdatePhraseAudio,
            .failedToSegmentPhraseAudioAtIndex,
            .onSegmentedPhrasesAudio,
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
