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
                var chapter: Chapter
                if case .existingStory(let storyId) = type {
                    chapter = state.createNewChapter(storyId: storyId)
                } else {
                    chapter = state.createNewChapter()
                }
                
                // Generate chapter content directly
                chapter = try await environment.generateChapter(chapter: chapter,
                                                               voice: state.settingsState.voice,
                                                               deviceLanguage: state.deviceLanguage,
                                                               currentSubscription: state.subscriptionState.currentSubscription)
                
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
            
        case .deleteChapter(let chapterId):
            // TODO: Implement chapter deletion in environment
            return .storyAction(.onDeletedChapter(chapterId))

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
            return nil

        case .onDeletedStory:
            return .storyAction(.loadStories(isAppLaunch: false))

        case .onLoadedChapters(let chapters, let isAppLaunch):
            return .storyAction(.onFinishedLoadedChapters)

        case .failedToCreateChapter:
            return .snackbarAction(.showSnackBar(.failedToWriteChapter))
        case .failedToLoadChapters,
                .failedToDeleteStory,
                .failedToDeleteChapter,
                .failedToSaveChapter,
                .updateAutoScrollEnabled,
                .updateCurrentSentence,
                .updatePlaybackTime,
                .onCreatedChapter,
                .onDeletedChapter,
                .onSavedChapter,
                .setCurrentStory,
                .updateLoadingState:
            return nil
        }
    default:
        return nil
    }
}
