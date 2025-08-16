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
        
    case .selectChapter(let storyId):
        // Load definitions for the selected chapter if available, starting with first sentence
        if let chapters = state.storyChapters[storyId],
           let selectedChapter = chapters.last {
            return .loadDefinitionsForChapter(selectedChapter, sentenceIndex: 0)
        }
        return nil
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
        
        // Check if any word in this sentence needs definitions
        let sentenceNeedsDefinitions = sentence.timestamps.contains { timestamp in
            state.definitions[timestamp.word] == nil
        }
        
        // If all words in this sentence have definitions, move to next sentence
        if !sentenceNeedsDefinitions {
            let nextIndex = sentenceIndex + 1
            if nextIndex < chapter.sentences.count {
                return .loadDefinitionsForChapter(chapter, sentenceIndex: nextIndex)
            }
            return nil
        }
        
        // Fetch definitions for this sentence
        do {
            let sentenceDefinitions = try await environment.studyEnvironment.fetchDefinitions(
                in: sentence,
                chapter: chapter,
                deviceLanguage: Language.deviceLanguage
            )
            
            // Only add new definitions (not already in state)
            let newDefinitions = sentenceDefinitions.filter { definition in
                state.definitions[definition.word] == nil
            }
            
            if !newDefinitions.isEmpty {
                // Return the loaded definitions
                return .onLoadedDefinitions(newDefinitions)
            } else {
                // No new definitions for this sentence, continue with next sentence
                let nextIndex = sentenceIndex + 1
                if nextIndex < chapter.sentences.count {
                    return .loadDefinitionsForChapter(chapter, sentenceIndex: nextIndex)
                }
                return nil
            }
        } catch {
            return .failedToLoadDefinitions
        }
        
    case .onLoadedDefinitions(let definitions):
        // After loading definitions, continue loading for the next sentence
        if let currentChapter = state.currentChapter {
            // Find the next sentence that needs definitions
            for (index, sentence) in currentChapter.sentences.enumerated() {
                let needsDefinitions = sentence.timestamps.contains { timestamp in
                    state.definitions[timestamp.word] == nil && !definitions.contains { $0.word == timestamp.word }
                }
                if needsDefinitions {
                    return .loadDefinitionsForChapter(currentChapter, sentenceIndex: index)
                }
            }
            // All definitions loaded, save the chapter
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
