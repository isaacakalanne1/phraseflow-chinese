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
    case .generateNewStory(let categories):
            do {
                let story = try await environment.generateStory(categories: categories)
                return .onGeneratedStory(story)
            } catch {
                return .failedToGenerateNewStory
            }
    case .onGeneratedStory(let story):
        return .generateNewChapter(story: story, index: 0)
    case .generateNewChapter(let story, let index):
            do {
                let newSentences = try await environment.generateChapter(using: story, chapterIndex: index, difficulty: .HSK1)
                let chapter = Chapter(sentences: newSentences, index: index)
                return .onGeneratedNewChapter(chapter)
            } catch {
                return .failedToGenerateNewChapter
            }
    case .onGeneratedNewChapter:
        return nil
    case .loadStory(let info):
        do {
            let story = try environment.loadStory(info: info)
            return .onLoadedStory(story)
        } catch {
            return .failedToLoadStory
        }
    case .onLoadedStory:
        return nil
    case .saveStory(let story):
        guard let story else {
            return .failedToSaveStory
        }
        do {
            try environment.saveStory(story)
            return nil
        } catch {
            return .failedToSaveStory
        }
    case .goToNextSentence:
        return nil
    case .synthesizeAudio(let sentence):
        do {
            let result = try await environment.synthesizeSpeech(for: sentence)
            return .onSynthesizedAudio(result)
        } catch {
            return .failedToPlayAudio
        }
    case .onSynthesizedAudio(let result):
        return nil
    case .playAudio(let timestamp):
        if let timestamp {
            state.audioPlayer?.currentTime = timestamp
        }
        state.audioPlayer?.play()
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
    case .failedToGenerateNewStory,
            .failedToGenerateNewChapter,
            .failedToLoadStory,
            .failedToSaveStory,
            .updateSpeechSpeed,
            .onDefinedCharacter,
            .failedToDefineCharacter,
            .onPlayedAudio,
            .failedToPlayAudio,
            .updateShowPinyin,
            .updateShowMandarin,
            .updateShowEnglish,
            .updateShowingCreateStoryScreen,
            .updateSelectCategory:
        return nil
    }
}
