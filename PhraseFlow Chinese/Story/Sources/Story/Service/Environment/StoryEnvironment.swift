//
//  StoryEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Loading
import Settings
import TextGeneration
import Speech
import Study
import ImageGeneration
import TextPractice
import UserLimit
import Combine

public struct StoryEnvironment: StoryEnvironmentProtocol {
    public let audioEnvironment: AudioEnvironmentProtocol
    public let studyEnvironment: StudyEnvironmentProtocol
    public let loadingEnvironment: LoadingEnvironmentProtocol
    public let textPracticeEnvironment: TextPracticeEnvironmentProtocol
    public var goToNextChapterSubject: CurrentValueSubject<Void?, Never> {
        textPracticeEnvironment.goToNextChapterSubject
    }
    public let userLimitEnvironment: UserLimitEnvironmentProtocol
    public var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never> {
        userLimitEnvironment.limitReachedSubject
    }
    private let settingsEnvironment: SettingsEnvironmentProtocol
    private let speechEnvironment: SpeechEnvironmentProtocol
    private let textGenerationService: TextGenerationServicesProtocol
    private let imageGenerationService: ImageGenerationServicesProtocol
    private let dataStore: StoryDataStoreProtocol

    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> {
        settingsEnvironment.settingsUpdatedSubject
    }
    
    public init(
        audioEnvironment: AudioEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol,
        speechEnvironment: SpeechEnvironmentProtocol,
        studyEnvironment: StudyEnvironmentProtocol,
        textPracticeEnvironment: TextPracticeEnvironmentProtocol,
        loadingEnvironment: LoadingEnvironmentProtocol,
        userLimitEnvironment: UserLimitEnvironmentProtocol,
        textGenerationService: TextGenerationServicesProtocol,
        imageGenerationService: ImageGenerationServicesProtocol,
        dataStore: StoryDataStoreProtocol
    ) {
        self.audioEnvironment = audioEnvironment
        self.settingsEnvironment = settingsEnvironment
        self.speechEnvironment = speechEnvironment
        self.studyEnvironment = studyEnvironment
        self.textPracticeEnvironment = textPracticeEnvironment
        self.loadingEnvironment = loadingEnvironment
        self.userLimitEnvironment = userLimitEnvironment
        self.textGenerationService = textGenerationService
        self.imageGenerationService = imageGenerationService
        self.dataStore = dataStore
    }
    
    public func saveAppSettings(_ settings: SettingsState) throws {
        try settingsEnvironment.saveAppSettings(settings)
    }
    
    public func limitReached(_ event: LimitReachedEvent) {
        limitReachedSubject.send(event)
    }
    
    public func generateTextForChapter(
        previousChapters: [Chapter] = [],
        language: Language? = nil,
        difficulty: Difficulty? = nil,
        voice: Voice? = nil,
        deviceLanguage: Language?,
        storyPrompt: String? = nil
    ) async throws -> Chapter {
        loadingEnvironment.updateLoadingStatus(.writing)

        let chapterWithStory = try await textGenerationService.generateChapterStory(
            previousChapters: previousChapters,
            language: language,
            difficulty: difficulty,
            voice: voice,
            storyPrompt: storyPrompt
        )
        
        loadingEnvironment.updateLoadingStatus(.formattingSentences)
        
        let finalChapter = try await textGenerationService.formatStoryIntoSentences(
            chapter: chapterWithStory,
            deviceLanguage: deviceLanguage
        )
        
        return finalChapter
    }
    
    public func generateChapterStory(
        previousChapters: [Chapter],
        language: Language?,
        difficulty: Difficulty?,
        voice: Voice?,
        storyPrompt: String?
    ) async throws -> Chapter {
        loadingEnvironment.updateLoadingStatus(.writing)
        
        return try await textGenerationService.generateChapterStory(
            previousChapters: previousChapters,
            language: language,
            difficulty: difficulty,
            voice: voice,
            storyPrompt: storyPrompt
        )
    }
    
    public func formatStoryIntoSentences(
        chapter: Chapter,
        deviceLanguage: Language?
    ) async throws -> Chapter {
        loadingEnvironment.updateLoadingStatus(.formattingSentences)
        
        return try await textGenerationService.formatStoryIntoSentences(
            chapter: chapter,
            deviceLanguage: deviceLanguage
        )
    }
    
    public func generateImageForChapter(
        _ chapter: Chapter,
        previousChapters: [Chapter] = []
    ) async throws -> Chapter {
        loadingEnvironment.updateLoadingStatus(.generatingImage)

        var processedChapter = chapter
        if processedChapter.imageData == nil && !processedChapter.passage.isEmpty {
            if let firstChapter = previousChapters.first, let existingImageData = firstChapter.imageData {
                processedChapter.imageData = existingImageData
            } else {
                processedChapter.imageData = try await imageGenerationService.generateImage(with: processedChapter.passage)
            }
        }
        
        return processedChapter
    }
    
    public func generateSpeechForChapter(
        _ chapter: Chapter
    ) async throws -> Chapter {
        loadingEnvironment.updateLoadingStatus(.generatingSpeech)

        let voiceToUse = chapter.audioVoice
        let finalChapter = try await speechEnvironment.synthesizeSpeech(
            for: chapter,
            voice: voiceToUse,
            language: chapter.language
        )
        
        return finalChapter
    }
    
    public func generateDefinitionsForChapter(
        _ chapter: Chapter,
        deviceLanguage: Language?
    ) async throws -> Chapter {
        loadingEnvironment.updateLoadingStatus(.generatingDefinitions)
        
        let sentencesToProcess = Array(chapter.sentences.prefix(3))
        var allDefinitions: [Definition] = []
        
        for sentence in sentencesToProcess {
            do {
                let definitions = try await studyEnvironment.fetchDefinitions(
                    in: sentence,
                    chapter: chapter,
                    deviceLanguage: deviceLanguage ?? Language.deviceLanguage
                )
                allDefinitions.append(contentsOf: definitions)
            } catch {
                print("Failed to fetch definitions for sentence: \(error)")
            }
        }
        
        if !allDefinitions.isEmpty {
            try studyEnvironment.saveDefinitions(allDefinitions)
        }

        loadingEnvironment.updateLoadingStatus(.complete)
        return chapter
    }

    // MARK: Chapters

    public func saveChapter(_ chapter: Chapter) throws {
        
        var chapterToSave = chapter
        
        do {
            let allChapters = try dataStore.loadAllChapters(for: chapter.storyId)
            let isFirstChapter = allChapters.isEmpty || allChapters.allSatisfy { $0.id == chapter.id }
            
            if !isFirstChapter {
                chapterToSave.imageData = nil
            }
            
            try dataStore.saveChapter(chapterToSave)
        } catch {
            throw error
        }
    }
    
    public func loadAllChapters() throws -> [Chapter] {
        try dataStore.loadAllChapters()
    }
    
    public func deleteChapter(_ chapter: Chapter) throws {
        try dataStore.deleteChapter(chapter)
    }
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
    
    public func cleanupDefinitionsNotInChapters(_ chapters: [Chapter]) throws {
        try studyEnvironment.cleanupDefinitionsNotInChapters(chapters)
    }
    
    public func cleanupOrphanedSentenceAudioFiles() throws {
        try studyEnvironment.cleanupOrphanedSentenceAudioFiles()
    }
}
