//
//  StoryMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import AVKit
import Foundation
import ReduxKit
import Settings
import Subscription
import TextGeneration

nonisolated(unsafe) public let storyMiddleware: Middleware<StoryState, StoryAction, any StoryEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .createChapter(let type):
        do {
            let chapter: Chapter

            switch type {
            case .newStory:
                // For now, we'll use default values since we can't access other package state
                chapter = try await environment.generateFirstChapter(
                    language: .mandarinChinese,
                    difficulty: .beginner,
                    voice: .xiaoxiao,
                    deviceLanguage: Language.deviceLanguage,
                    storyPrompt: nil,
                    currentSubscription: nil
                )
                
            case .existingStory(let storyId):
                if let existingChapters = state.storyChapters[storyId] {
                    chapter = try await environment.generateChapter(
                        previousChapters: existingChapters,
                        deviceLanguage: nil,
                        currentSubscription: nil
                    )
                } else {
                    return .failedToCreateChapter
                }

            }
            
            return .onCreatedChapter(chapter)
        } catch {
            return .failedToCreateChapter
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
    case .onLoadedStoriesAndDefitions:
        // Simply return nil - cross-package actions should be handled by the main app
        return nil

    case .deleteStory(let storyId):
        do {
            // Delete all chapters for this story
            if let chapters = state.storyChapters[storyId] {
                for chapter in chapters {
                    try environment.deleteChapter(chapter)
                }
            }
            return .onDeletedStory(storyId)
        } catch {
            return .failedToDeleteStory
        }


    case .saveChapter(let chapter):
        print("[StoryMiddleware] saveChapter action received")
        print("[StoryMiddleware] Chapter ID: \(chapter.id)")
        print("[StoryMiddleware] Story ID: \(chapter.storyId)")
        
        do {
            print("[StoryMiddleware] About to call environment.saveChapter")
            print("[StoryMiddleware] Environment type: \(type(of: environment))")
            print("[StoryMiddleware] Calling environment.saveChapter directly")
            
            try environment.saveChapter(chapter)
            print("[StoryMiddleware] saveChapter completed, calling saveAppSettings")
            try environment.saveAppSettings(state)
            print("[StoryMiddleware] saveAppSettings completed")
            return .onSavedChapter(chapter)
        } catch {
            print("[StoryMiddleware] Error saving chapter: \(error)")
            print("[StoryMiddleware] Error type: \(type(of: error))")
            print("[StoryMiddleware] Error localized: \(error.localizedDescription)")
            return .failedToSaveChapter
        }

    case .goToNextChapter:
        if let currentChapter = state.currentChapter {
            return .saveChapter(currentChapter)
        }
        return nil

    case .failedToCreateChapter:
        // Cross-package actions should be handled by the main app
        return nil
        
    case .onCreatedChapter(let chapter):
        // Return a save action to handle the save operation properly
        return .saveChapter(chapter)
        
    case .selectWord(let word, let shouldPlay):
        // Cross-package definition logic should be handled by the main app
        return shouldPlay ? .playWord(word) : nil
        
    case .selectChapter:
        // Cross-package definition logic should be handled by the main app
        return nil
        
    case .playWord(let timestamp):
//        var speechSpeed = SpeechSpeed.normal
//        if let settings = try? environment.getAppSettings() {
//            speechSpeed = settings.speechSpeed
//        } // TODO: Get app settings on store initialization/on appear, and update local app settings whenever updated in settings package
        environment.playWord(timestamp, rate: SpeechSpeed.normal.playRate)
        return nil
    case .playChapter(let word):
        environment.playChapter(from: word)
        environment.setMusicVolume(.quiet)
        return nil
    case .pauseChapter:
        environment.pauseChapter()
        environment.setMusicVolume(.normal)
        return nil
    case .updateSpeechSpeed(let speed):
        do {
            try environment.updateSpeechSpeed(speed)
        } catch {
            // Handle error silently for now
        }
        return nil
        
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
