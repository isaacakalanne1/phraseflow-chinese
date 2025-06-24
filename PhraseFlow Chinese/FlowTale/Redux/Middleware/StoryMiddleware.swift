//
//  StoryMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import AVKit
import Foundation
import ReduxKit

let storyMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .storyAction(let storyAction):
        switch storyAction {
        case .createChapter(let type):
            do {
                let chapter: Chapter

                switch type {
                case .newStory:
                    chapter = try await environment.generateFirstChapter(
                        language: state.settingsState.language,
                        difficulty: state.settingsState.difficulty,
                        voice: state.settingsState.voice,
                        deviceLanguage: state.deviceLanguage,
                        storyPrompt: state.settingsState.storySetting.prompt,
                        currentSubscription: state.subscriptionState.currentSubscription
                    )
                    
                case .existingStory(let storyId):
                    if let existingChapters = state.storyState.storyChapters[storyId] {
                        chapter = try await environment.generateChapter(
                            previousChapters: existingChapters,
                            deviceLanguage: state.deviceLanguage,
                            currentSubscription: state.subscriptionState.currentSubscription
                        )
                    } else {
                        throw FlowTaleServicesError.failedToGetResponseData
                    }

                }
                
                return .storyAction(.onCreatedChapter(chapter))
            } catch FlowTaleDataStoreError.freeUserCharacterLimitReached {
                return nil
            } catch FlowTaleDataStoreError.characterLimitReached(let nextAvailable) {
                return nil
            } catch {
                return nil
            }

        case .loadChapters(let storyId, let isAppLaunch):
            do {
                // Load chapters for a specific story
                let chapters = try environment.loadAllChapters(for: storyId)
                return .storyAction(.onLoadedChapters(chapters, isAppLaunch: isAppLaunch))
            } catch {
                return .storyAction(.failedToLoadChapters)
            }
        
        case .loadStories(let isAppLaunch):
            do {
                // Load all chapters directly
                let chapters = try environment.loadAllChapters()
                return .storyAction(.onLoadedChapters(chapters, isAppLaunch: isAppLaunch))
            } catch {
                return .storyAction(.failedToLoadChapters)
            }

        case .deleteStory(let storyId):
            do {
                // Delete all chapters for this story
                if let chapters = state.storyState.storyChapters[storyId] {
                    for chapter in chapters {
                        try environment.deleteChapter(chapter)
                    }
                }
                return .storyAction(.onDeletedStory(storyId))
            } catch {
                return .storyAction(.failedToDeleteStory)
            }

        case .saveChapter(let chapter):
            do {
                try environment.saveChapter(chapter)
                try environment.saveAppSettings(state.settingsState)
                return .storyAction(.onSavedChapter(chapter))
            } catch {
                return .storyAction(.failedToSaveChapter)
            }

        case .goToNextChapter:
            if let currentChapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(currentChapter))
            }
            return nil
            
        case .goToPreviousChapter:
            if let currentChapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(currentChapter))
            }
            return nil
            
        case .goToChapter:
            if let currentChapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(currentChapter))
            }
            return nil

        case .onFinishedLoadedChapters:
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
                    return .definitionAction(.loadRemainingDefinitions(sentenceIndex: sentenceIndex, previousDefinitions: []))
                }
            }
            return .navigationAction(.selectTab(.reader, shouldPlaySound: false))

        case .onDeletedStory:
            return .storyAction(.loadStories(isAppLaunch: false))

        case .onLoadedChapters(let chapters, let isAppLaunch):
            return .storyAction(.onFinishedLoadedChapters)

        case .failedToCreateChapter:
            return .snackbarAction(.showSnackBar(.failedToWriteChapter))
        case .onCreatedChapter(let chapter):
            return .definitionAction(.loadInitialSentenceDefinitions(chapter))
        case .selectWord(let word, let shouldPlay):
            return shouldPlay ? .audioAction(.playWord(word)) : nil
        case .failedToLoadChapters,
                .failedToDeleteStory,
                .failedToSaveChapter,
                .updateAutoScrollEnabled,
                .updateCurrentSentence,
                .onSavedChapter,
                .setCurrentStory,
                .updateLoadingState:
            return nil
        }
    default:
        return nil
    }
}
