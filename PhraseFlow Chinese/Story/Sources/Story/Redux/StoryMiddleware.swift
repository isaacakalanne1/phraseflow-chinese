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
import Study
import Subscription
import TextGeneration

nonisolated(unsafe) public let storyMiddleware: Middleware<StoryState, StoryAction, any StoryEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .createChapter(let type):
        do {
            var chapters: [Chapter] = []
            if case .existingStory(let storyId) = type,
               let existingChapters = state.storyChapters[storyId] {
                chapters = existingChapters
            }
            
            let chapter = try await environment.generateChapter(
                previousChapters: chapters,
                language: .mandarinChinese,
                difficulty: .beginner,
                voice: .xiaoxiao,
                deviceLanguage: Language.deviceLanguage,
                storyPrompt: nil,
                currentSubscription: nil
            )
            
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
        do {
            try environment.saveChapter(chapter)
            try environment.saveAppSettings(state)
            return .onSavedChapter(chapter)
        } catch {
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
        // Load definitions for the chapter after creation
        return .loadDefinitionsForChapter(chapter)
        
    case .selectWord(let word, let shouldPlay):
        await environment.playWord(word, rate: SpeechSpeed.normal.playRate)
        return nil
        
    case .selectChapter(let storyId):
        // Load definitions for the selected chapter if available
        if let chapters = state.storyChapters[storyId],
           let selectedChapter = chapters.last {
            return .loadDefinitionsForChapter(selectedChapter)
        }
        return nil
    case .prepareToPlayChapter(let chapter):
        await environment.prepareToPlayChapter(chapter)
        return nil
    case .playChapter(let word):
        await environment.playChapter(from: word)
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
        
    case .playSound(let sound):
        environment.playSound(sound)
        return nil
        
    case .loadDefinitionsForChapter(let chapter):
        // Get unique characters from all sentences
        var uniqueCharacters = Set<String>()
        for sentence in chapter.sentences {
            for timestamp in sentence.timestamps {
                uniqueCharacters.insert(timestamp.word)
            }
        }
        
        // Fetch definitions through study environment
        do {
            var definitions: [Definition] = []
            for sentence in chapter.sentences {
                let sentenceDefinitions = try await environment.studyEnvironment.fetchDefinitions(
                    in: sentence,
                    chapter: chapter,
                    deviceLanguage: Language.deviceLanguage
                )
                definitions.append(contentsOf: sentenceDefinitions)
            }
            return .onLoadedDefinitions(definitions)
        } catch {
            return .failedToLoadDefinitions
        }
        
    case .onLoadedDefinitions:
        // Save chapter after definitions are loaded
        if let currentChapter = state.currentChapter {
            return .saveChapter(currentChapter)
        }
        return nil
        
    case .failedToLoadStoriesAndDefinitions,
            .failedToDeleteStory,
            .failedToSaveChapter,
            .updateCurrentSentence,
            .onSavedChapter,
            .onDeletedStory,
            .setPlaybackTime,
            .updateLoadingStatus,
            .failedToLoadDefinitions,
            .showDefinition,
            .hideDefinition:
        return nil
    }
}
