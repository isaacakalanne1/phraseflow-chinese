//
//  StoryMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Audio
import AVKit
import Foundation
import ReduxKit
import Settings
import Study
import TextGeneration
import TextPractice
import UserLimit

@MainActor
public let storyMiddleware: Middleware<StoryState, StoryAction, StoryEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .createChapter(let type):
        switch state.settings.subscriptionLevel {
        case .free:
            let remainingCharacters = environment.userLimitEnvironment.getRemainingFreeCharacters()
            if remainingCharacters <= 0 {
                environment.limitReachedSubject.send(.freeLimit)
                return .failedToCreateChapter
            }
        default:
            let remainingCharacters = environment.userLimitEnvironment.getRemainingDailyCharacters(characterLimitPerDay: state.settings.characterLimitPerDay)
            if remainingCharacters <= 0 {
                let timeUntilReset = environment.userLimitEnvironment.getTimeUntilNextDailyReset(characterLimitPerDay: state.settings.characterLimitPerDay) ?? "24 hours"
                environment.limitReachedSubject.send(.dailyLimit(nextAvailable: timeUntilReset))
                return .failedToCreateChapter
            }
        }
        return .generateText(type)
        
    case .generateText(let type):
        do {
            var chapters: [Chapter] = []
            if case .existingStory(let storyId) = type,
               let existingChapters = state.storyChapters[storyId] {
                chapters = existingChapters
            }
            
            let chapter = try await environment.generateTextForChapter(
                previousChapters: chapters,
                language: state.settings.language,
                difficulty: state.settings.difficulty,
                voice: state.settings.voice,
                deviceLanguage: Language.deviceLanguage,
                storyPrompt: state.settings.storySetting.prompt
            )
            
            return .onGeneratedText(chapter)
        } catch {
            return .failedToCreateChapter
        }
        
    case .onGeneratedText(let chapter):
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
        environment.playSound(sound)
        return nil
        
    case .beginGetNextChapter:
        if state.isLastChapter,
           let id = state.currentChapter?.storyId {
            return .createChapter(.existingStory(id))
        }
        return .goToNextChapter
    case .failedToLoadStoriesAndDefinitions,
            .failedToDeleteStory,
            .failedToSaveChapter,
            .onSavedChapter,
            .onDeletedStory,
            .failedToCreateChapter,
            .onCreatedChapter,
            .selectChapter,
            .onLoadedStories,
            .refreshAppSettings:
        return nil
    }
}
