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
        loadingEnvironment: LoadingEnvironmentProtocol,
        service: TextGenerationServicesProtocol,
        imageGenerationService: ImageGenerationServicesProtocol,
        dataStore: StoryDataStoreProtocol
    ) {
        self.audioEnvironment = audioEnvironment
        self.settingsEnvironment = settingsEnvironment
        self.speechEnvironment = speechEnvironment
        self.studyEnvironment = studyEnvironment
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
    
    public func deleteChapter(_ chapter: Chapter) throws {
        try dataStore.deleteChapter(chapter)
    }
    
    public func getAppSettings() throws -> SettingsState {
        try settingsEnvironment.loadAppSettings()
    }
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
}
