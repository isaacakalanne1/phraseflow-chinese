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
        return .generateNewChapter(story: story)
    case .generateNewChapter(let story):
            do {
                let newSentences = try await environment.generateChapter(using: story)
                let chapter = Chapter(sentences: newSentences)
                return .onGeneratedNewChapter(chapter: chapter)
            } catch {
                return .failedToGenerateNewChapter
            }
    case .onGeneratedNewChapter:
        if let story = state.currentStory {
            return .saveStory(story)
        } else {
            return nil
        }
    case .loadStories:
        do {
            let stories = try environment.loadStories()
            return .onLoadedStories(stories)
        } catch {
            return .failedToLoadStories
        }
    case .onLoadedStories:
        return nil
    case .saveStory(let story):
        do {
            try environment.saveStory(story)
            return .loadStories
        } catch {
            return .failedToSaveStory
        }
    case .goToNextSentence,
            .goToPreviousSentence:
        if let sentence = state.currentSentence {
            return .synthesizeAudio(sentence)
        }
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
    case .selectStory,
            .selectChapter:
        return .updateShowingStoryListView(isShowing: false)
    case .failedToGenerateNewStory,
            .failedToGenerateNewChapter,
            .failedToLoadStories,
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
            .updateSelectCategory,
            .updateShowingSettings,
            .updateShowingStoryListView:
        return nil
    }
}
