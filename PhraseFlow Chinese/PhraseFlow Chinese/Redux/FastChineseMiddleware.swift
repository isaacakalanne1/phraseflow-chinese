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
        return .saveStory(story)
    case .generateChapter(let previousChapter):
        do {
            let chapterResponse = try await environment.generateChapter(previousChapter: previousChapter)
            return .onGeneratedChapter(chapterResponse)
        } catch {
            return .failedToGenerateChapter
        }
    case .onGeneratedChapter:
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
        return .refreshChapterView
    case .saveStory(let story):
        do {
            try environment.saveStory(story)
            return .loadStories
        } catch {
            return .failedToSaveStory
        }
    case .synthesizeAudio(let chapter, let isForced):
        if chapter.audioData != nil && !isForced {
            return .playAudio(time: nil)
        }
        do {
            let result = try await environment.synthesizeSpeech(for: chapter)
            return .onSynthesizedAudio(result)
        } catch {
            return .failedToPlayAudio
        }
    case .onSynthesizedAudio(let result):
        if let story = state.currentStory {
            return .saveStory(story)
        }
        return nil
    case .playAudio(let timestamp):
        if let timestamp {
            state.audioPlayer?.currentTime = timestamp
        }
        state.audioPlayer?.prepareToPlay()
        state.audioPlayer?.play()
        return nil
    case .playWord(let word):
        state.audioPlayer?.currentTime = word.time + 0.05
        state.audioPlayer?.play()
        let duration = word.duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            state.audioPlayer?.stop()
        }
        return nil
    case .pauseAudio,
            .stopAudio:
        state.audioPlayer?.stop()
        return nil
    case .defineCharacter(let timeStampData, let shouldForce):
        do {
            guard let sentence = state.currentSentence else {
                return nil
            }
            let definition = try await environment.fetchDefinition(of: timeStampData.word, withinContextOf: sentence, shouldForce: shouldForce)
            return .onDefinedCharacter(definition)
        } catch {
            return .failedToDefineCharacter
        }
    case .onDefinedCharacter:
        return .refreshDefinitionView
    case .selectStory,
            .selectChapter:
        if let story = state.currentStory {
            return .saveStory(story)
        }
        return nil
    case .selectWord(let timestampData):
        state.audioPlayer?.currentTime = timestampData.time
        return nil
    case .goToNextChapter:
        if let story = state.currentStory {
            return .saveStory(story)
        }
        return nil
    case .updatePlayTime:
        if let time = state.audioPlayer?.currentTime,
           let lastWordTime = state.currentChapter?.timestampData.last?.time,
           time > lastWordTime {
            return .stopAudio
        } else {
            return nil
        }
    case .failedToGenerateNewStory,
            .failedToLoadStories,
            .failedToSaveStory,
            .updateSpeechSpeed,
            .failedToDefineCharacter,
            .onPlayedAudio,
            .failedToPlayAudio,
            .updateShowPinyin,
            .updateShowDefinition,
            .updateShowEnglish,
            .updateShowingCreateStoryScreen,
            .updateSelectCategory,
            .updateShowingSettings,
            .updateShowingStoryListView,
            .failedToGenerateChapter,
            .updateSentenceIndex,
            .refreshChapterView,
            .refreshDefinitionView:
        return nil
    }
}
