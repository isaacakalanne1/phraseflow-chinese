//
//  StoryEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine
import Loading
import Settings
import TextGeneration
import Speech
import Subscription
import Study
import ImageGeneration
import TextPractice

public struct StoryEnvironment: StoryEnvironmentProtocol {
    public let audioEnvironment: AudioEnvironmentProtocol
    public let studyEnvironment: StudyEnvironmentProtocol
    public let loadingEnvironment: LoadingEnvironmentProtocol
    public let textPracticeEnvironment: TextPracticeEnvironmentProtocol
    private let settingsEnvironment: SettingsEnvironmentProtocol
    private let speechEnvironment: SpeechEnvironmentProtocol
    private let service: TextGenerationServicesProtocol
    private let imageGenerationService: ImageGenerationServicesProtocol
    private let dataStore: StoryDataStoreProtocol
    
    public init(
        audioEnvironment: AudioEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol,
        speechEnvironment: SpeechEnvironmentProtocol,
        studyEnvironment: StudyEnvironmentProtocol,
        textPracticeEnvironment: TextPracticeEnvironmentProtocol,
        loadingEnvironment: LoadingEnvironmentProtocol,
        service: TextGenerationServicesProtocol,
        imageGenerationService: ImageGenerationServicesProtocol,
        dataStore: StoryDataStoreProtocol
    ) {
        self.audioEnvironment = audioEnvironment
        self.settingsEnvironment = settingsEnvironment
        self.speechEnvironment = speechEnvironment
        self.studyEnvironment = studyEnvironment
        self.textPracticeEnvironment = textPracticeEnvironment
        self.loadingEnvironment = loadingEnvironment
        self.service = service
        self.imageGenerationService = imageGenerationService
        self.dataStore = dataStore
    }
    
    public func generateChapter(
        previousChapters: [Chapter] = [],
        language: Language? = nil,
        difficulty: Difficulty? = nil,
        voice: Voice? = nil,
        deviceLanguage: Language?,
        storyPrompt: String? = nil,
        currentSubscription: SubscriptionLevel?
    ) async throws -> Chapter {
        loadingEnvironment.updateLoadingStatus(.writing)

        let newChapter: Chapter
        if previousChapters.isEmpty {
            guard let language = language,
                  let difficulty = difficulty,
                  let voice = voice else {
                throw NSError(domain: "StoryEnvironment", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters for first chapter"])
            }
            newChapter = try await service.generateFirstChapter(
                language: language,
                difficulty: difficulty,
                voice: voice,
                deviceLanguage: deviceLanguage,
                storyPrompt: storyPrompt
            )
        } else {
            newChapter = try await service.generateChapter(
                previousChapters: previousChapters,
                deviceLanguage: deviceLanguage
            )
        }
        
        loadingEnvironment.updateLoadingStatus(.generatingImage)

        var processedChapter = newChapter
        if processedChapter.imageData == nil && !processedChapter.passage.isEmpty {
            if let firstChapter = previousChapters.first, let existingImageData = firstChapter.imageData {
                processedChapter.imageData = existingImageData
            } else {
                processedChapter.imageData = try await imageGenerationService.generateImage(with: processedChapter.passage)
            }
        }
        
        loadingEnvironment.updateLoadingStatus(.generatingSpeech)

        let voiceToUse = processedChapter.audioVoice
        let (finalChapter, ssmlCharacterCount) = try await speechEnvironment.synthesizeSpeechWithCharacterCount(
            for: processedChapter,
            voice: voiceToUse,
            language: processedChapter.language
        )

        try trackSSMLCharacterUsage(
            characterCount: ssmlCharacterCount,
            subscription: currentSubscription
        )
        
        loadingEnvironment.updateLoadingStatus(.generatingDefinitions)
        
        let sentencesToProcess = Array(finalChapter.sentences.prefix(3))
        var allDefinitions: [Definition] = []
        
        for sentence in sentencesToProcess {
            do {
                let definitions = try await studyEnvironment.fetchDefinitions(
                    in: sentence,
                    chapter: finalChapter,
                    deviceLanguage: deviceLanguage ?? Language.deviceLanguage
                )
                allDefinitions.append(contentsOf: definitions)
            } catch {
                // Continue with other sentences even if one fails
                print("Failed to fetch definitions for sentence: \(error)")
            }
        }
        
        // Save the definitions if any were generated
        if !allDefinitions.isEmpty {
            try studyEnvironment.saveDefinitions(allDefinitions)
        }

        loadingEnvironment.updateLoadingStatus(.complete)
        return finalChapter
    }
    
    public func saveDefinitions(_ definitions: [Definition]) throws {
        try studyEnvironment.saveDefinitions(definitions)
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
    
    public func prepareToPlayChapter(_ chapter: Chapter) async {
        await audioEnvironment.setChapterAudioData(chapter.audio.data)
    }
    
    public func playWord(
        _ word: WordTimeStampData,
        rate: Float
    ) async {
        await audioEnvironment.playWord(startTime: word.time, duration: word.duration, playRate: rate)

    }
    
    public func playChapter(from word: WordTimeStampData) async {
        await audioEnvironment.playChapterAudio(from: word.time,
                                                rate: SpeechSpeed.normal.playRate)

    }
    
    public func pauseChapter() {
        audioEnvironment.pauseChapterAudio()
    }
    
    public func setMusicVolume(_ volume: MusicVolume) {
        audioEnvironment.setMusicVolume(volume)
    }
    
    private func trackSSMLCharacterUsage(
        characterCount: Int,
        subscription: SubscriptionLevel?
    ) throws {
        // This would normally track SSML character usage
        // For now, do nothing to fix compilation
    }
    
    public func loadAllChapters() throws -> [Chapter] {
        try dataStore.loadAllChapters()
    }
    
    public func loadDefinitions() throws -> [Definition] {
        return try studyEnvironment.loadDefinitions()
    }
    
    public func deleteChapter(_ chapter: Chapter) throws {
        try dataStore.deleteChapter(chapter)
    }
    
    // MARK: - Settings Environment Functions
    
    public func getAppSettings() throws -> SettingsState {
        try settingsEnvironment.loadAppSettings()
    }
    
    public func isShowingEnglish() throws -> Bool {
        let settings = try settingsEnvironment.loadAppSettings()
        return settings.isShowingEnglish
    }
    
    public func isShowingDefinition() throws -> Bool {
        let settings = try settingsEnvironment.loadAppSettings()
        return settings.isShowingDefinition
    }
    
    public func getSpeechSpeed() throws -> SpeechSpeed {
        let settings = try settingsEnvironment.loadAppSettings()
        return settings.speechSpeed
    }
    
    public func updateSpeechSpeed(_ speed: SpeechSpeed) throws {
        var settings = try settingsEnvironment.loadAppSettings()
        settings.speechSpeed = speed
        try settingsEnvironment.saveAppSettings(settings)
    }
    
    // MARK: - Audio Environment Functions
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
    
    // MARK: - Definition Environment Functions
    
    public func getCurrentDefinition() -> Definition? {
        // This would need to track current definition in the environment
        // For now, return nil as a placeholder
        return nil
    }
    
    public func getDefinition(for timestampData: WordTimeStampData) -> Definition? {
        // This would need to look up a definition by timestamp data
        // For now, return nil as a placeholder
        return nil
    }
    
    public func hasDefinition(for timestampData: WordTimeStampData) -> Bool {
        return getDefinition(for: timestampData) != nil
    }
    
    public func getDefinitions() -> [Definition] {
        // This would need to get all definitions
        // For now, return empty array as a placeholder
        return []
    }
    
    // MARK: - Translation Environment Functions
    
    public func getCurrentTranslationSentence() -> Sentence? {
        // This would need to track current translation sentence
        // For now, return nil as a placeholder
        return nil
    }
    
    public func getTranslationChapter() -> Chapter? {
        // This would need to get the translation chapter
        // For now, return nil as a placeholder
        return nil
    }
}
