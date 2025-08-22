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
            
            let settings = try environment.getAppSettings()
            
            let chapter = try await environment.generateChapter(
                previousChapters: chapters,
                language: settings.language,
                difficulty: settings.difficulty,
                voice: settings.voice,
                deviceLanguage: Language.deviceLanguage,
                storyPrompt: settings.storySetting.prompt,
                currentSubscription: nil
            )
            
            try environment.saveChapter(chapter)
            
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
        // Load definitions for the chapter after creation, starting with first sentence
        return .loadDefinitionsForChapter(chapter, sentenceIndex: 0)
        
    case .selectWord(let word, let shouldPlay):
        await environment.playWord(word, rate: SpeechSpeed.normal.playRate)
        return nil
        
    case .selectChapter(let chapter):
        return .loadDefinitionsForChapter(chapter, sentenceIndex: 0)
    case .prepareToPlayChapter(let chapter):
        await environment.prepareToPlayChapter(chapter)
        return .loadDefinitionsForChapter(chapter, sentenceIndex: 0)
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
        
    case .loadDefinitionsForChapter(let chapter, let sentenceIndex):
        // Check if sentenceIndex is valid
        guard sentenceIndex < chapter.sentences.count else {
            return nil
        }
        
        let sentence = chapter.sentences[sentenceIndex]
        
        // Fetch definitions for this sentence - the environment will handle checking what's already loaded
        do {
            let sentenceDefinitions = try await environment.studyEnvironment.fetchDefinitions(
                in: sentence,
                chapter: chapter,
                deviceLanguage: Language.deviceLanguage
            )
            if !sentenceDefinitions.isEmpty {
                // Return the loaded definitions with context
                return .onLoadedDefinitions(sentenceDefinitions, chapter: chapter, sentenceIndex: sentenceIndex)
            } else {
                // No definitions returned for this sentence, continue with next sentence
                try? environment.saveDefinitions(sentenceDefinitions)
                let nextIndex = sentenceIndex + 1
                if nextIndex < chapter.sentences.count {
                    return .loadDefinitionsForChapter(chapter, sentenceIndex: nextIndex)
                }
                return nil
            }
        } catch {
            return .failedToLoadDefinitions
        }
        
    case .onLoadedDefinitions(let definitions, let chapter, let sentenceIndex):
        // Continue loading definitions for the next sentence
        let nextIndex = sentenceIndex + 1
        if nextIndex < chapter.sentences.count {
            return .loadDefinitionsForChapter(chapter, sentenceIndex: nextIndex)
        } else {
            // All sentences processed, save the chapter if it's the current one
            if state.currentChapter?.id == chapter.id {
                return .saveChapter(chapter)
            }
        }
        return nil
        
    case .showDefinition(let wordTimestamp):
        if let definition = state.definitions[wordTimestamp.word] {
            try? environment.saveDefinitions([definition])
            // TODO: Save sentence audio
            // TODO: Get definition (word) audio to play (may also need to be saved if not already)
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
            .hideDefinition:
        return nil
    }
}
