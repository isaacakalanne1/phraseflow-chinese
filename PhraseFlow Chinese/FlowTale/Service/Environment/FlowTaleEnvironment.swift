//
//  FlowTaleEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Combine
import Foundation
import StoreKit
import Story

struct FlowTaleEnvironment: FlowTaleEnvironmentProtocol {
    private let service: FlowTaleServicesProtocol
    private let dataStore: FlowTaleDataStoreProtocol
    private let repository: FlowTaleRepositoryProtocol

    public let loadingSubject: CurrentValueSubject<LoadingState?, Never> = .init(nil)
    public let chapterSubject: CurrentValueSubject<Chapter?, Never> = .init(nil)
    public let storyEnvironment: StoryEnvironmentProtocol

    init() {
        service = FlowTaleServices()
        dataStore = FlowTaleDataStore()
        repository = FlowTaleRepository()
        storyEnvironment = StoryEnvironment()
        try? cleanupOrphanedDefinitionFiles()
        try? cleanupOrphanedSentenceAudioFiles()
    }

    func synthesizeSpeech(for chapter: Chapter,
                          voice: Voice,
                          language: Language) async throws -> Chapter
    {
        let (processedChapter, _) = try await repository.synthesizeSpeech(chapter,
                                                                         voice: voice,
                                                                         language: language)
        return processedChapter
    }
    
    func synthesizeSpeechWithCharacterCount(
        _ chapter: Chapter,
        voice: Voice,
        language: Language
    ) async throws -> (Chapter, Int) {
        return try await repository.synthesizeSpeech(chapter,
                                                    voice: voice,
                                                    language: language)
    }

    func getProducts() async throws -> [Product] {
        try await repository.getProducts()
    }

    func generateChapter(previousChapters: [Chapter],
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
                newChapter.imageData = try await service.generateImage(with: newChapter.passage)
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

    func generateFirstChapter(language: Language,
                              difficulty: Difficulty,
                              voice: Voice,
                              deviceLanguage: Language?,
                              storyPrompt: String?,
                              currentSubscription: SubscriptionLevel?) async throws -> Chapter {
        loadingSubject.send(.writing)

        var newChapter = try await service.generateFirstChapter(language: language,
                                                               difficulty: difficulty,
                                                               voice: voice,
                                                               deviceLanguage: deviceLanguage,
                                                               storyPrompt: storyPrompt)
        loadingSubject.send(.generatingImage)

        if newChapter.imageData == nil,
           !newChapter.passage.isEmpty {
            newChapter.imageData = try await service.generateImage(with: newChapter.passage)
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

    func saveChapter(_ chapter: Chapter) throws {
        var chapterToSave = chapter
        
        // Only save cover art in the first chapter to save memory
        let allChapters = try dataStore.loadAllChapters(for: chapter.storyId)
        let isFirstChapter = allChapters.isEmpty || allChapters.allSatisfy { $0.id == chapter.id }
        
        if !isFirstChapter {
            chapterToSave.imageData = nil
        }
        
        try dataStore.saveChapter(chapterToSave)
    }

    func loadAllChapters() throws -> [Chapter] {
        try dataStore.loadAllChapters()
    }
    
    func deleteChapter(_ chapter: Chapter) throws {
        try dataStore.deleteChapter(chapter)
    }

    func saveAppSettings(_ settings: SettingsState) throws {
        try dataStore.saveAppSettings(settings)
    }

    func loadDefinitions() throws -> [Definition] {
        try dataStore.loadDefinitions()
    }

    func saveDefinitions(_ definitions: [Definition]) throws {
        try dataStore.saveDefinitions(definitions)
    }

    func deleteDefinition(with id: UUID) throws {
        try dataStore.deleteDefinition(with: id)
    }

    func cleanupOrphanedDefinitionFiles() throws {
        try dataStore.cleanupOrphanedDefinitionFiles()
    }

    // MARK: - Sentence Audio

    func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        try dataStore.saveSentenceAudio(audioData, id: id)
    }

    func loadSentenceAudio(id: UUID) throws -> Data {
        try dataStore.loadSentenceAudio(id: id)
    }

    func cleanupOrphanedSentenceAudioFiles() throws {
        try dataStore.cleanupOrphanedSentenceAudioFiles()
    }

    func loadAppSettings() throws -> SettingsState {
        try dataStore.loadAppSettings()
    }

    func fetchDefinitions(in sentence: Sentence?,
                          chapter: Chapter,
                          deviceLanguage: Language) async throws -> [Definition]
    {
        try await service.fetchDefinitions(in: sentence,
                                           chapter: chapter,
                                           deviceLanguage: deviceLanguage)
    }

    func purchase(_ product: Product) async throws {
        try await repository.purchase(product)
    }

    func validateReceipt() {
        repository.validateAppStoreReceipt()
    }

    func moderateText(_ text: String) async throws -> ModerationResponse {
        try await service.moderateText(text)
    }

    func trackSSMLCharacterUsage(characterCount: Int, subscription: SubscriptionLevel?) throws {
        try dataStore.trackSSMLCharacterUsage(characterCount: characterCount, subscription: subscription)
    }
    
    func translateText(
        _ text: String,
        from sourceLanguage: Language?,
        to targetLanguage: Language
    ) async throws -> Chapter {
        try await service.translateText(text, from: sourceLanguage, to: targetLanguage)
    }
    
    func breakdownText(
        _ text: String,
        textLanguage: Language,
        deviceLanguage: Language
    ) async throws -> Chapter {
        try await service.breakdownText(text, textLanguage: textLanguage, deviceLanguage: deviceLanguage)
    }
}
