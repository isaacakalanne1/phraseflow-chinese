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

@MainActor
public let storyMiddleware: Middleware<StoryState, StoryAction, StoryEnvironmentProtocol> = { state, action, environment in
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
        
    case .onCreatedChapter(let chapter):
        // Chapter creation handled - definitions will be loaded by TextPractice
        return nil
        
    case .selectWord(let word, let shouldPlay):
        await environment.playWord(word, rate: SpeechSpeed.normal.playRate)
        return nil
        
    case .selectChapter(let chapter):
        // Chapter selection handled - definitions will be loaded by TextPractice
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
        
    case .beginGetNextChapter:
        if state.isLastChapter,
           let id = state.currentChapter?.storyId {
            return .createChapter(.existingStory(id))
        }
        return .goToNextChapter
        
    case .failedToLoadStoriesAndDefinitions,
            .failedToDeleteStory,
            .failedToSaveChapter,
            .updateCurrentSentence,
            .onSavedChapter,
            .onDeletedStory,
            .failedToCreateChapter,
            .onLoadedStories:
        return nil
    }
}
