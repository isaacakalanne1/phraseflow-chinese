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
    case .generateNewStory(let genres):
        do {
            let story = try await environment.generateStory(genres: genres)
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
    case .deleteStory(let story):
        do {
            try environment.unsaveStory(story)
            return .loadStories
        } catch {
            return .failedToDeleteStory
        }
    case .synthesizeAudio(let chapter, let voice, let isForced):
        if chapter.audioData != nil && !isForced {
            return .playAudio(time: nil)
        }
        do {
            let result = try await environment.synthesizeSpeech(for: chapter, voice: voice)
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
            let myTime = CMTime(seconds: timestamp, preferredTimescale: 60000)
            await state.audioPlayer.seek(to: myTime, toleranceBefore: .indefinite, toleranceAfter: .zero)
        }
        state.audioPlayer.playImmediately(atRate: state.speechSpeed.rate)
        return nil
    case .playWord(let word):
        let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
        await state.audioPlayer.seek(to: myTime, toleranceBefore: .indefinite, toleranceAfter: .zero)
        state.audioPlayer.playImmediately(atRate: state.speechSpeed.rate)
        return nil
    case .pauseAudio,
            .stopAudio,
            .finishedPlayingWord:
        state.audioPlayer.pause()
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
        let myTime = CMTime(seconds: timestampData.time, preferredTimescale: 60000)
        await state.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        return nil
    case .goToNextChapter:
        if let story = state.currentStory {
            return .saveStory(story)
        }
        return nil
    case .updatePlayTime:
        let time = state.audioPlayer.currentTime().seconds
        if let lastWordTime = state.currentChapter?.timestampData.last?.time,
           time > lastWordTime {
            return .stopAudio
        } else {
            return nil
        }
    case .selectVoice(let voice):
        do {
            try environment.saveVoice(voice)
            return nil
        } catch {
            return .failedToSaveVoice
        }
    case .loadVoice:
        do {
            let voice = try environment.loadVoice()
            return .onLoadedVoice(voice)
        } catch {
            return .failedToLoadVoice
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
            .updateSelectGenre,
            .updateShowingSettings,
            .updateShowingStoryListView,
            .failedToGenerateChapter,
            .updateSentenceIndex,
            .refreshChapterView,
            .refreshDefinitionView,
            .selectStorySetting,
            .failedToDeleteStory,
            .failedToSaveVoice,
            .onLoadedVoice,
            .failedToLoadVoice:
        return nil
    }
}
