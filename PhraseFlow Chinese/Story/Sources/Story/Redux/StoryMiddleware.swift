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
import TextGeneration

@MainActor
public let storyMiddleware: Middleware<StoryState, StoryAction, StoryEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .createChapter(let type):
        guard state.settings.remainingCharacters > 0 else {
            return .failedToCreateChapter
        }
        return .generateText(type)
    case .failedToCreateChapter:
        if state.settings.remainingCharacters <= 0 {
            environment.limitReached(state.settings.subscriptionLevel == .free ? .freeLimit : .dailyLimit(nextAvailable: "text here"))
        }
        return nil
    case .generateText(let type):
        do {
            var chapters: [Chapter] = []
            if case .existingStory(let storyId) = type,
               let existingChapters = state.storyChapters[storyId] {
                chapters = existingChapters
            }
            
            let chapter = try await environment.generateChapterStory(
                previousChapters: chapters,
                language: state.settings.language,
                difficulty: state.settings.difficulty,
                voice: state.settings.voice,
                storyPrompt: state.settings.storySetting.prompt
            )
            
            return .onGeneratedText(chapter)
        } catch {
            return .failedToCreateChapter
        }
        
    case .onGeneratedText(let chapter):
        return .formatSentences(chapter)
        
    case .formatSentences(let chapter):
        do {
            let formattedChapter = try await environment.formatStoryIntoSentences(
                chapter: chapter,
                deviceLanguage: Language.deviceLanguage
            )
            return .onFormattedSentences(formattedChapter)
        } catch {
            return .failedToCreateChapter
        }
        
    case .onFormattedSentences(let chapter):
        return .generateImage(chapter)
        
    case .generateImage(let chapter):
        do {
            let previousChapters = state.storyChapters[chapter.storyId] ?? []
            let chapterWithImage = try await environment.generateImageForChapter(
                chapter,
                previousChapters: previousChapters
            )
            return .onGeneratedImage(chapterWithImage)
        } catch {
            return .failedToCreateChapter
        }
        
    case .onGeneratedImage(let chapter):
        return .generateSpeech(chapter)
        
    case .generateSpeech(let chapter):
        do {
            let chapter = try await environment.generateSpeechForChapter(chapter)
            return .onGeneratedSpeech(chapter)
        } catch {
            return .failedToCreateChapter
        }
        
    case .onGeneratedSpeech(let chapter):
        return .generateDefinitions(chapter)
        
    case .generateDefinitions(let chapter):
        do {
            let finalChapter = try await environment.generateDefinitionsForChapter(
                chapter,
                deviceLanguage: Language.deviceLanguage
            )
            return .onGeneratedDefinitions(finalChapter)
        } catch {
            return .failedToCreateChapter
        }
        
    case .onGeneratedDefinitions(let chapter):
        do {
            try environment.saveChapter(chapter)
            
            return .onCreatedChapter(chapter)
        } catch {
            return .failedToCreateChapter
        }
    
    case .loadStories:
        do {
            // Load all chapters directly
            let chapters = try environment.loadAllChapters()
            try environment.cleanupDefinitionsNotInChapters(chapters)
            try environment.cleanupOrphanedSentenceAudioFiles()
            return .onLoadedStories(chapters)
        } catch {
            return .failedToLoadStoriesAndDefinitions
        }

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
            return .onSavedChapter(chapter)
        } catch {
            return .failedToSaveChapter
        }

    case .goToNextChapter:
        if let currentChapter = state.currentChapter {
            return .saveChapter(currentChapter)
        }
        return nil
        
    case .playSound(let sound):
        if state.settings.shouldPlaySound {
            environment.playSound(sound)
        }
        return nil
        
    case .beginGetNextChapter:
        if state.isLastChapter,
           let id = state.currentChapter?.storyId {
            return .createChapter(.existingStory(id))
        }
        return .goToNextChapter
    case .saveAppSettings(let settings):
        try? environment.saveAppSettings(settings)
        return nil
    case .updateLanguage:
        if state.settings.shouldPlaySound {
            environment.playSound(.tabPress)
        }
        return .saveAppSettings(state.settings)
    case .failedToLoadStoriesAndDefinitions,
            .failedToDeleteStory,
            .failedToSaveChapter,
            .onSavedChapter,
            .onDeletedStory,
            .onCreatedChapter,
            .selectChapter,
            .onLoadedStories,
            .refreshAppSettings:
        return nil
    }
}
