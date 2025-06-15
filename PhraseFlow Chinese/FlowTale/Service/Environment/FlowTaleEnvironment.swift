//
//  FlowTaleEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Combine
import Foundation
import StoreKit

struct FlowTaleEnvironment: FlowTaleEnvironmentProtocol {
    let service: FlowTaleServicesProtocol
    let dataStore: FlowTaleDataStoreProtocol
    let repository: FlowTaleRepositoryProtocol

    public let loadingSubject: CurrentValueSubject<LoadingState?, Never> = .init(nil)

    init() {
        service = FlowTaleServices()
        dataStore = FlowTaleDataStore()
        repository = FlowTaleRepository()
        try? cleanupOrphanedDefinitionFiles()
        try? cleanupOrphanedSentenceAudioFiles()
    }

    func synthesizeSpeech(for chapter: Chapter,
                          story: Story,
                          voice: Voice,
                          language: Language) async throws -> Chapter
    {
        let (processedChapter, _) = try await repository.synthesizeSpeech(chapter,
                                                                         story: story,
                                                                         voice: voice,
                                                                         language: language)
        return processedChapter
    }
    
    func synthesizeSpeechWithCharacterCount(
        _ chapter: Chapter,
        story: Story,
        voice: Voice,
        language: Language
    ) async throws -> (Chapter, Int) {
        return try await repository.synthesizeSpeech(chapter,
                                                    story: story,
                                                    voice: voice,
                                                    language: language)
    }

    func getProducts() async throws -> [Product] {
        try await repository.getProducts()
    }

    func generateStory(story: Story,
                       voice: Voice,
                       deviceLanguage: Language?,
                       currentSubscription: SubscriptionLevel?) async throws -> Story {
        loadingSubject.send(.writing)

        var newStory = try await service.generateStory(story: story, deviceLanguage: deviceLanguage)
        loadingSubject.send(.generatingImage)

        if newStory.imageData == nil,
           let passage = newStory.chapters.first?.passage {
            newStory.imageData = try await service.generateImage(with: passage)
        }
        loadingSubject.send(.generatingSpeech)

        guard let chapter = newStory.chapters.last else {
            throw FlowTaleRepositoryError.failedToPurchaseSubscription
        }
        let (newChapter, ssmlCharacterCount) = try await synthesizeSpeechWithCharacterCount(
            chapter,
            story: newStory,
            voice: voice,
            language: newStory.language
        )

        try trackSSMLCharacterUsage(
            characterCount: ssmlCharacterCount,
            subscription: currentSubscription
        )

        newStory.chapters.removeLast()
        newStory.chapters.append(newChapter)

        loadingSubject.send(.complete)
        return newStory
    }

    // MARK: Stories

    func saveStory(_ story: Story) throws {
        for (index, chapter) in story.chapters.enumerated() {
            try saveChapter(chapter, storyId: story.id, chapterIndex: index + 1)
        }
        try dataStore.saveStory(story)
    }

    func loadAllStories() throws -> [Story] {
        try dataStore.loadAllStories()
    }

    // MARK: Chapter

    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws {
        try dataStore.saveChapter(chapter, storyId: storyId, chapterIndex: chapterIndex)
    }

    func loadAllChapters(for storyId: UUID) throws -> [Chapter] {
        try dataStore.loadAllChapters(for: storyId)
    }

    func saveAppSettings(_ settings: SettingsState) throws {
        try dataStore.saveAppSettings(settings)
    }

    func unsaveStory(_ story: Story) throws {
        try dataStore.unsaveStory(story)
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
                          story: Story,
                          deviceLanguage: Language) async throws -> [Definition]
    {
        try await service.fetchDefinitions(in: sentence,
                                           story: story,
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
