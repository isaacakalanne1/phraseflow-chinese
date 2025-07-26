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
import Subscription
import Study
import Translation

@MainActor
public struct StoryEnvironment: StoryEnvironmentProtocol {
    public let storySubject = CurrentValueSubject<UUID?, Never>(nil)
    public let loadingSubject: CurrentValueSubject<LoadingStatus?, Never> = .init(nil)
    private let chapterSubject = CurrentValueSubject<Chapter?, Never>(nil)
    
    private let audioEnvironment: AudioEnvironmentProtocol
    private let settingsEnvironment: SettingsEnvironmentProtocol
    private let studyEnvironment: StudyEnvironmentProtocol
    private let translationEnvironment: TranslationEnvironmentProtocol
    private let service: TextGenerationServicesProtocol
    private let dataStore: StoryDataStoreProtocol
    
    public init(
        audioEnvironment: AudioEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol,
        studyEnvironment: StudyEnvironmentProtocol,
        translationEnvironment: TranslationEnvironmentProtocol,
        service: TextGenerationServicesProtocol,
        dataStore: StoryDataStoreProtocol
    ) {
        self.audioEnvironment = audioEnvironment
        self.settingsEnvironment = settingsEnvironment
        self.studyEnvironment = studyEnvironment
        self.translationEnvironment = translationEnvironment
        self.service = service
        self.dataStore = dataStore
    }
    
    public func selectChapter(storyId: UUID) {
        storySubject.send(storyId)
    }
    
    public func generateChapter(previousChapters: [Chapter],
                         deviceLanguage: Language?,
                         currentSubscription: SubscriptionLevel?) async throws -> Chapter {
        loadingSubject.send(.writing)

        var newChapter = try await service.generateChapter(previousChapters: previousChapters,
                                                           deviceLanguage: deviceLanguage)
        loadingSubject.send(.generatingImage)

        if newChapter.imageData == nil,
           !newChapter.passage.isEmpty {
            if let firstChapter = previousChapters.first, let existingImageData = firstChapter.imageData {
                newChapter.imageData = existingImageData
            } else {
                // TODO: Image generation should be handled through separate ImageGeneration environment
                // newChapter.imageData = try await service.generateImage(with: newChapter.passage)
            }
        }
        loadingSubject.send(.generatingSpeech)

        let voiceToUse = newChapter.audioVoice
        let (processedChapter, ssmlCharacterCount) = try await synthesizeSpeechWithCharacterCount(
            newChapter,
            voice: voiceToUse,
            language: newChapter.language
        )

        try trackSSMLCharacterUsage(
            characterCount: ssmlCharacterCount,
            subscription: currentSubscription
        )

        chapterSubject.send(processedChapter)
        loadingSubject.send(.complete)
        return processedChapter
    }

    public func generateFirstChapter(language: Language,
                              difficulty: Difficulty,
                              voice: Voice,
                              deviceLanguage: Language?,
                              storyPrompt: String?,
                              currentSubscription: SubscriptionLevel?) async throws -> Chapter {
        loadingSubject.send(.writing)

        let newChapter = try await service.generateFirstChapter(language: language,
                                                               difficulty: difficulty,
                                                               voice: voice,
                                                               deviceLanguage: deviceLanguage,
                                                               storyPrompt: storyPrompt)
        loadingSubject.send(.generatingImage)

        if newChapter.imageData == nil,
           !newChapter.passage.isEmpty {
            // TODO: Image generation should be handled through separate ImageGeneration environment
            // newChapter.imageData = try await service.generateImage(with: newChapter.passage)
        }
        loadingSubject.send(.generatingSpeech)

        let voiceToUse = newChapter.audioVoice
        let (processedChapter, ssmlCharacterCount) = try await synthesizeSpeechWithCharacterCount(
            newChapter,
            voice: voiceToUse,
            language: newChapter.language
        )

        try trackSSMLCharacterUsage(
            characterCount: ssmlCharacterCount,
            subscription: currentSubscription
        )

        chapterSubject.send(processedChapter)
        loadingSubject.send(.complete)
        return processedChapter
    }

    // MARK: Chapters

    public func saveChapter(_ chapter: Chapter) throws {
        var chapterToSave = chapter
        
        // Only save cover art in the first chapter to save memory
        let allChapters = try dataStore.loadAllChapters(for: chapter.storyId)
        let isFirstChapter = allChapters.isEmpty || allChapters.allSatisfy { $0.id == chapter.id }
        
        if !isFirstChapter {
            chapterToSave.imageData = nil
        }
        
        try dataStore.saveChapter(chapterToSave)
    }
    
    public func playWord(
        _ word: WordTimeStampData,
        rate: Float
    ) {
        Task {
            await audioEnvironment.playWord(startTime: word.time, duration: word.duration, playRate: rate)
        }
    }
    
    public func getAppSettings() throws -> SettingsState {
        try settingsEnvironment.loadAppSettings()
    }
    
    public func playChapter(from word: WordTimeStampData) {
        Task {
            await audioEnvironment.playChapterAudio(from: word.time,
                                              rate: SpeechSpeed.normal.playRate)
        }
    }
    
    public func pauseChapter() {
        audioEnvironment.pauseChapterAudio()
    }
    
    public func setMusicVolume(_ volume: MusicVolume) {
        audioEnvironment.setMusicVolume(volume)
    }
    
    private func synthesizeSpeechWithCharacterCount(
        _ chapter: Chapter,
        voice: Voice,
        language: Language
    ) async throws -> (Chapter, Int) {
        // This would normally synthesize speech and return the processed chapter with character count
        // For now, return the chapter as-is with 0 character count to fix compilation
        return (chapter, 0)
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
        // This would normally load definitions from another environment
        // For now, return empty array to fix compilation
        return []
    }
    
    public func deleteChapter(_ chapter: Chapter) throws {
        try dataStore.deleteChapter(chapter)
    }
    
    public func saveAppSettings(_ state: StoryState) throws {
        // This would normally save app settings through settings environment
        // For now, do nothing to fix compilation
    }
    
    // MARK: - Settings Environment Functions
    
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
    
    public func isPlayingAudio() -> Bool {
        // Since AudioEnvironmentProtocol doesn't have this method,
        // we'll need to implement this differently or add it to AudioEnvironmentProtocol
        // For now, return false as a placeholder
        return false
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
