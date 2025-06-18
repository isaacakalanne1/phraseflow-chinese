//
//  StoryMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

let storyMiddleware: Middleware<FlowTaleState, StoryAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
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
            return .onCreatedChapter(story)
        } catch FlowTaleDataStoreError.freeUserCharacterLimitReached {
            return nil
        } catch FlowTaleDataStoreError.characterLimitReached(let nextAvailable) {
            return nil
        } catch {
            return nil
        }

    case .onCreatedChapter(let story):
        return nil

    case .loadStories(let isAppLaunch):
        do {
            let stories = try environment.loadAllStories()
                .sorted(by: { $0.lastUpdated > $1.lastUpdated })
            return .onLoadedStories(stories, isAppLaunch: isAppLaunch)
        } catch {
            return .failedToLoadStories
        }
        
    case .loadChapters(let story, let isAppLaunch):
        do {
            let chapters = try environment.loadAllChapters(for: story.id)
            return .onLoadedChapters(story, chapters, isAppLaunch: isAppLaunch)
        } catch {
            return .failedToLoadChapters
        }
        
    case .deleteStory(let story):
        do {
            try environment.unsaveStory(story)
            return .onDeletedStory(story.id)
        } catch {
            return .failedToDeleteStory
        }
        
    case .onDeletedStory:
        return .loadStories(isAppLaunch: false)
        
    case .saveStoryAndSettings(var story):
        do {
            try environment.saveStory(story)
            try environment.saveAppSettings(state.settingsState)
        } catch {
            return nil
        }
        return nil
        
    case .goToNextChapter:
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
        
    case .onLoadedStories(let stories, let isAppLaunch):
        return .onFinishedLoadedStories
        
    case .onFinishedLoadedStories:
        if let story = state.storyState.currentStory,
           story.chapters.isEmpty {
            return .loadChapters(story, isAppLaunch: false)
        }
        return nil
        
    case .onLoadedChapters(let story, let chapters, let isAppLaunch):
        return nil
        
    default:
        return nil
    }
}
