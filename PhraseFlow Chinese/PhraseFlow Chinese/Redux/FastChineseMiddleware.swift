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
        var newSentences: [Sentence] = []
            do {
                newSentences = try await environment.generateChapter(using: .init(storyOverview: "", difficulty: ""))
            } catch {
                return .failedToGenerateNewChapter
            }
        return .onGeneratedNewChapter(newSentences)
    case .onGeneratedNewChapter:
        return .saveSentences
    case .loadChapter(let info, let chapterIndex):
        do {
            let chapter = try environment.loadChapter(info: info, chapterIndex: chapterIndex)
            return .onLoadedChapter(chapter)
        } catch {
            return .failedToLoadChapter
        }
    case .onLoadedChapter:
        return .preloadAudio
    case .saveSentences:
        do {
            try environment.saveChapter(.init(sentences: state.sentences,
                                              index: 0,
                                              info: .init(storyOverview: "",
                                                          difficulty: "")))
        } catch {
            return .failedToSaveSentences
        }
        return .preloadAudio
    case .submitAnswer:
        return .revealAnswer
    case .goToNextSentence:
        return .preloadAudio
    case .preloadAudio:
        do {
            guard state.sentences.count > 0 else {
                return nil
            }
            var sentences: [Sentence] = []
            var audioDataList: [Data] = []
            for i in 0..<2 {
                let index = (state.sentenceIndex + i) % state.sentences.count
                let sentence = state.sentences[index]
                if sentence.audioData == nil {
                    let audioData = try await environment.fetchSpeech(for: sentence)
                    sentences.append(sentence)
                    audioDataList.append(audioData)
                }
            }
            return .updateSentencesAudio(sentences, audioDataList: audioDataList)
        } catch {
            return .failedToPreloadAudio
        }

    case .updateSentencesAudio(let sentences, let audioDataList):
        do {
            var audioUrlList: [URL] = []
            for (sentence, audioData) in zip(sentences, audioDataList) {
                let audioURL = try environment.saveAudioToTempFile(fileName: sentence.mandarin, data: audioData)
                audioUrlList.append(audioURL)
            }
            return nil
        } catch {
            return .failedToUpdateSentencesAudio
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
            guard let mandarinSentence = state.currentSentence?.mandarin else {
                return nil
            }
            let response = try await environment.fetchDefinition(of: string, withinContextOf: mandarinSentence)
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

    case .failedToGenerateNewChapter,
            .failedToLoadChapter,
            .failedToSaveSentences,
            .revealAnswer,
            .failedToPreloadAudio,
            .failedToUpdateSentencesAudio,
            .failedToUpdateAudioPlayer,
            .updateSpeechSpeed,
            .onDefinedCharacter,
            .failedToDefineCharacter,
            .updatePracticeMode,
            .updateUserInput:
        return nil
    }
}
