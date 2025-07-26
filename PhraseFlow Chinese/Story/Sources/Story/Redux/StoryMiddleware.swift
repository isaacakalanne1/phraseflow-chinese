//
//  StoryMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import AVKit
import Foundation
import ReduxKit
import Subscription
import TextGeneration

@MainActor
let storyMiddleware: Middleware<StoryState, StoryAction, StoryEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .createChapter(let type):
        do {
            let chapter: Chapter

            switch type {
            case .newStory:
                chapter = try await environment.generateFirstChapter(
                    language: state.language,
                    difficulty: state.difficulty,
                    voice: state.voice,
                    deviceLanguage: nil,
                    storyPrompt: state.storySetting.prompt,
                    currentSubscription: state.subscriptionState.currentSubscription
                )
                
            case .existingStory(let storyId):
                if let existingChapters = state.storyState.storyChapters[storyId] {
                    chapter = try await environment.generateChapter(
                        previousChapters: existingChapters,
                        deviceLanguage: nil,
                        currentSubscription: state.subscriptionState.currentSubscription
                    )
                } else {
                    throw TextGenerationServicesError.failedToGetResponseData
                }

            }
            
            return .onCreatedChapter(chapter)
        } catch UserLimitsDataStoreError.freeUserCharacterLimitReached {
            return nil
        } catch UserLimitsDataStoreError.characterLimitReached(let nextAvailable) {
            return nil
        } catch {
            return nil
        }
    
    case .loadStoriesAndDefinitions:
        do {
            // Load all chapters directly
            let chapters = try environment.loadAllChapters()
            let definitions = try environment.loadDefinitions()
            return .onLoadedStoriesAndDefitions(chapters, definitions)
        } catch {
            return .failedToLoadStoriesAndDefinitions
        }
    case .onLoadedStoriesAndDefitions(let chapters, let definitions):
        if let currentChapter = state.storyState.currentChapter {
            let existingDefinitions = state.definitionState.definitions
            var firstMissingSentenceIndex: Int?

            for (sentenceIndex, sentence) in currentChapter.sentences.enumerated() {
                let sentenceHasDefinitions = sentence.timestamps.allSatisfy { timestamp in
                    existingDefinitions.contains { $0.timestampData == timestamp }
                }

                if !sentenceHasDefinitions {
                    firstMissingSentenceIndex = sentenceIndex
                    break
                }
            }

            if let sentenceIndex = firstMissingSentenceIndex {
                return .definitionAction(.defineSentence(sentenceIndex: sentenceIndex, previousDefinitions: [], chapter: currentChapter, deviceLanguage: nil))
            }
        }
        return .navigationAction(.selectTab(.reader, shouldPlaySound: false))

    case .deleteStory(let storyId):
        do {
            // Delete all chapters for this story
            if let chapters = state.storyState.storyChapters[storyId] {
                for chapter in chapters {
                    try environment.deleteChapter(chapter)
                }
            }
            return .onDeletedStory(storyId)
        } catch {
            return .failedToDeleteStory
        }


    case .saveChapter(let chapter):
        do {
            try environment.saveChapter(chapter)
            try environment.saveAppSettings(state)
            return .onSavedChapter(chapter)
        } catch {
            return .failedToSaveChapter
        }

    case .goToNextChapter:
        if let currentChapter = state.storyState.currentChapter {
            return .saveChapter(currentChapter)
        }
        return nil

    case .failedToCreateChapter:
        return .snackbarAction(.showSnackBar(.failedToWriteChapter))
    case .onCreatedChapter(let chapter):
        try? environment.saveChapter(chapter)
        return .definitionAction(.defineSentence(sentenceIndex: 0, previousDefinitions: [], chapter: chapter, deviceLanguage: nil))
    case .selectWord(let word, let shouldPlay):
        if let definition = state.definitionState.definition(timestampData: word) {
            return .definitionAction(.showDefinition(definition, shouldPlay: shouldPlay))
        }
        return shouldPlay ? .playWord(word) : nil
    case .selectChapter(let storyId):
        if let chapters = state.storyState.storyChapters[storyId], !chapters.isEmpty {
            let selectedChapter = chapters.last ?? chapters[0]
            let existingDefinitions = state.definitionState.definitions
            var firstMissingSentenceIndex: Int?

            for (sentenceIndex, sentence) in selectedChapter.sentences.enumerated() {
                let sentenceHasDefinitions = sentence.timestamps.allSatisfy { timestamp in
                    existingDefinitions.contains { $0.timestampData == timestamp }
                }

                if !sentenceHasDefinitions {
                    firstMissingSentenceIndex = sentenceIndex
                    break
                }
            }

            if let sentenceIndex = firstMissingSentenceIndex {
                return .definitionAction(.defineSentence(sentenceIndex: sentenceIndex, previousDefinitions: [], chapter: currentChapter, deviceLanguage: nil))
            }
        }
        return nil
        
    case .playWord(let timestamp):
//        var speechSpeed = SpeechSpeed.normal
//        if let settings = try? environment.getAppSettings() {
//            speechSpeed = settings.speechSpeed
//        } // TODO: Get app settings on store initialization/on appear, and update local app settings whenever updated in settings package
        environment.playWord(timestamp, rate: SpeechSpeed.normal.playRate)
    case .playChapter(let word):
        environment.playChapter(from: word)
        environment.setMusicVolume(.quiet)
    case .pauseChapter:
        environment.pauseChapter()
        environment.setMusicVolume(.normal)
    case .failedToLoadStoriesAndDefinitions,
            .failedToDeleteStory,
            .failedToSaveChapter,
            .updateCurrentSentence,
            .onSavedChapter,
            .onDeletedStory,
            .setPlaybackTime,
            .updateLoadingStatus:
        return nil
    }
}
