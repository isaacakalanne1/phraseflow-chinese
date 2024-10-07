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
    case .generateNewChapter:
        var newPhrases: [Sentence] = []
            do {
                newPhrases = try await environment.generateChapter(using: <#T##ChapterGenerationInfo#>)
            } catch {
                return .failedToFetchNewPhrases
            }
        return .onFetchedNewPhrases(newPhrases)
    case .onFetchedNewPhrases:
        return .saveSentences
    case .fetchSavedPhrases:
        do {
            let phrases = try environment.fetchSavedPhrases()
            return .onFetchedSavedPhrases(phrases)
        } catch {
            return .failedToFetchSavedPhrases
        }
    case .onFetchedSavedPhrases:
        return .preloadAudio
    case .saveSentences:
        do {
            try environment.saveSentences(state.sentences)
        } catch {
            return .failedToSaveSentences
        }
        return .preloadAudio
    case .submitAnswer:
        return .revealAnswer
    case .goToNextPhrase:
        return .preloadAudio
    case .preloadAudio:
        do {
            guard state.sentences.count > 0 else {
                return nil
            }
            var phrases: [Sentence] = []
            var audioDataList: [Data] = []
            for i in 0..<2 {
                let index = (state.sentenceIndex + i) % state.sentences.count
                let phrase = state.sentences[index]
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
        do {
            var audioUrlList: [URL] = []
            for (phrase, audioData) in zip(phrases, audioDataList) {
                let audioURL = try environment.saveAudioToTempFile(fileName: phrase.mandarin, data: audioData)
                audioUrlList.append(audioURL)
            }
            return nil
        } catch {
            return .failedToUpdatePhraseAudio
        }
    case .playAudio:
        do {
            if let audioData = state.currentSentence?.audioData {
                let audioPlayer = try AVAudioPlayer(data: audioData)
                return .updateAudioPlayer(audioPlayer)
            }
            return nil
        } catch {
            return .failedToUpdateAudioPlayer
        }
    case .defineCharacter(let string):
        do {
            guard let mandarinPhrase = state.currentSentence?.mandarin else {
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
            .failedToSaveSentences,
            .failedToFetchSavedPhrases,
            .revealAnswer,
            .failedToPreloadAudio,
            .failedToUpdatePhraseAudio,
            .failedToUpdateAudioPlayer,
            .updateSpeechSpeed,
            .onDefinedCharacter,
            .failedToDefineCharacter,
            .updatePracticeMode,
            .updateUserInput:
        return nil
    }
}
