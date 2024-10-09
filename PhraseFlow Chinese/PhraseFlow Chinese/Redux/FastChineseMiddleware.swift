//
//  FastChineseMiddleware.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit

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
        return nil
    case .saveSentences:
        do {
            try environment.saveChapter(.init(sentences: state.sentences,
                                              index: 0,
                                              info: .init(storyOverview: "",
                                                          difficulty: "")))
        } catch {
            return .failedToSaveSentences
        }
        return nil
    case .goToNextSentence:
        return nil
    case .playAudio(let sentence):
        do {
            try environment.speakText(for: sentence)
        } catch {
            return .failedToPlayAudio
        }
        return nil
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
    case .failedToGenerateNewChapter,
            .failedToLoadChapter,
            .failedToSaveSentences,
            .updateSpeechSpeed,
            .onDefinedCharacter,
            .failedToDefineCharacter,
            .failedToPlayAudio:
        return nil
    }
}
