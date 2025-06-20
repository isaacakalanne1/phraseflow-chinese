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
                var story: Story
                if case .existingStory(let existingStory) = type {
                    story = existingStory
                } else {
                    story = state.createNewStory()
                }
                story = try await environment.generateStory(story: story,
                                                            voice: state.settingsState.voice,
                                                            deviceLanguage: state.deviceLanguage,
                                                            currentSubscription: state.subscriptionState.currentSubscription)
                return .storyAction(.onCreatedChapter(story))
            } catch FlowTaleDataStoreError.freeUserCharacterLimitReached {
                return nil
            } catch FlowTaleDataStoreError.characterLimitReached(let nextAvailable) {
                return nil
            } catch {
                return nil
            }

        case .loadStories(let isAppLaunch):
            do {
                let stories = try environment.loadAllStories()
                    .sorted(by: { $0.lastUpdated > $1.lastUpdated })
                return .storyAction(.onLoadedStories(stories, isAppLaunch: isAppLaunch))
            } catch {
                return .storyAction(.failedToLoadStories)
            }

        case .loadChapters(let story, let isAppLaunch):
            do {
                let chapters = try environment.loadAllChapters(for: story.id)
                return .storyAction(.onLoadedChapters(story,
                                                      chapters,
                                                      isAppLaunch: isAppLaunch))
            } catch {
                return .storyAction(.failedToLoadChapters)
            }

        case .deleteStory(let story):
            do {
                try environment.unsaveStory(story)
                return .storyAction(.onDeletedStory(story.id))
            } catch {
                return .storyAction(.failedToDeleteStory)
            }

        case .saveStoryAndSettings(var story):
            do {
                try environment.saveStory(story)
                try environment.saveAppSettings(state.settingsState)
            } catch {
                return .storyAction(.failedToSaveStoryAndSettings)
            }
            return nil

        case .goToNextChapter:
            if let story = state.storyState.currentStory {
                return .storyAction(.saveStoryAndSettings(story))
            }
            return nil

        case .onFinishedLoadedStories:
            if let story = state.storyState.currentStory,
               story.chapters.isEmpty {
                return .storyAction(.loadChapters(story, isAppLaunch: false))
            }
            return nil

        case .onDeletedStory:
            return .storyAction(.loadStories(isAppLaunch: false))

        case .onLoadedStories(let stories, let isAppLaunch):
            return .storyAction(.onFinishedLoadedStories)

        case .failedToCreateChapter:
            return .snackbarAction(.showSnackBar(.failedToWriteChapter))
        case .failedToLoadStories,
                .failedToLoadChapters,
                .failedToDeleteStory,
                .failedToSaveStoryAndSettings,
                .updateAutoScrollEnabled,
                .updateCurrentSentence,
                .onCreatedChapter,
                .onLoadedChapters,
                .updateLoadingState:
            return nil
        }
    default:
        return nil
    }
}
