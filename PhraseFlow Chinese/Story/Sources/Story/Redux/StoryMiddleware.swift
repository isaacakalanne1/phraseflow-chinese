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
import TextPractice

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
        
        // Check if definitions already exist for all words in this sentence
        let wordsInSentence = sentence.timestamps.map { $0.word }
        let existingDefinitions = wordsInSentence.compactMap { word in
            let key = DefinitionKey(word: word, sentenceId: sentence.id)
            return state.definitions[key]
        }
        
        // If we have definitions for all words in the sentence, skip fetching
        if existingDefinitions.count == wordsInSentence.count {
            return .onLoadedDefinitions(existingDefinitions, chapter: chapter, sentenceIndex: sentenceIndex)
        }

        do {
            let sentenceDefinitions = try await environment.studyEnvironment.fetchDefinitions(
                in: sentence,
                chapter: chapter,
                deviceLanguage: Language.deviceLanguage
            )
            try? environment.saveDefinitions(sentenceDefinitions)
            return .onLoadedDefinitions(sentenceDefinitions, chapter: chapter, sentenceIndex: sentenceIndex)
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
    case .beginGetNextChapter:
        if state.isLastChapter,
           let id = state.currentChapter?.storyId {
            return .createChapter(.existingStory(id))
        }
        return .goToNextChapter
        
    case .showDefinition(let wordTimestamp):
        // Find the definition for this word in the current sentence
        if let currentSentence = state.currentChapter?.currentSentence {
            let key = DefinitionKey(word: wordTimestamp.word, sentenceId: currentSentence.id)
            if let definition = state.definitions[key] {
                try? environment.saveDefinitions([definition])
                // TODO: Save sentence audio
                // TODO: Get definition (word) audio to play (may also need to be saved if not already)
            }
        }
        return nil
        
    case .failedToLoadStoriesAndDefinitions,
            .failedToDeleteStory,
            .failedToSaveChapter,
            .updateCurrentSentence,
            .onSavedChapter,
            .onDeletedStory,
            .updateLoadingStatus,
            .failedToLoadDefinitions,
            .hideDefinition:
        return nil
    }
}
