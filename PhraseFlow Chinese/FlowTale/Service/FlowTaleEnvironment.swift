//
//  FlowTaleEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import StoreKit

protocol FlowTaleEnvironmentProtocol {
    func synthesizeSpeech(for chapter: Chapter,
                          story: Story,
                          voice: Voice,
                          language: Language) async throws -> ChapterAudio
    func getProducts() async throws -> [Product]
    func generateStory(story: Story) async throws -> String
    func translateStory(story: Story, storyString: String, deviceLanguage: Language?) async throws -> Story
    
    // Definitions
    func loadDefinitions() throws -> [Definition]
    func loadDefinitions(for storyId: UUID) throws -> [Definition]
    func saveDefinitions(_ definitions: [Definition]) throws
    func saveDefinitions(for storyId: UUID, definitions: [Definition]) throws
    func deleteDefinitions(for storyId: UUID) throws
    func cleanupOrphanedDefinitionFiles() throws
    
    // Settings
    func loadAppSettings() throws -> SettingsState
    func saveAppSettings(_ settings: SettingsState) throws

    // Stories & Chapters
    func saveStory(_ story: Story) throws
    func loadAllStories() throws -> [Story]
    func unsaveStory(_ story: Story) throws

    // Chapters
    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws
    func loadChapter(storyId: UUID, chapterIndex: Int) throws -> Chapter
    func loadAllChapters(for storyId: UUID) throws -> [Chapter]

    func fetchDefinitions(for sentenceIndex: Int,
                          in sentence: Sentence,
                          chapter: Chapter,
                          story: Story,
                          deviceLanguage: Language?) async throws -> [Definition]
    func purchase(_ product: Product) async throws
    func validateReceipt()
    func generateImage(with prompt: String) async throws -> Data
    func moderateText(_ text: String) async throws -> ModerationResponse
    func enforceChapterCreationLimit(subscription: SubscriptionLevel?) throws
}

struct FlowTaleEnvironment: FlowTaleEnvironmentProtocol {

    let service: FlowTaleServicesProtocol
    let dataStore: FlowTaleDataStoreProtocol
    let repository: FlowTaleRepositoryProtocol

    init() {
        self.service = FlowTaleServices()
        self.dataStore = FlowTaleDataStore()
        self.repository = FlowTaleRepository()
    }

    func synthesizeSpeech(for chapter: Chapter,
                          story: Story,
                          voice: Voice,
                          language: Language) async throws -> ChapterAudio {
        try await repository.synthesizeSpeech(chapter,
                                              story: story,
                                              voice: voice,
                                              language: language)
    }

    func getProducts() async throws -> [Product] {
        try await repository.getProducts()
    }

    func generateStory(story: Story) async throws -> String {
        try await service.generateStory(story: story)
    }

    func translateStory(story: Story, storyString: String, deviceLanguage: Language?) async throws -> Story {
        try await service.translateStory(story: story, storyString: storyString, deviceLanguage: deviceLanguage)
    }

    // MARK: Stories

    func saveStory(_ story: Story) throws {
        try dataStore.saveStory(story)
    }

    func loadAllStories() throws -> [Story] {
        try dataStore.loadAllStories()
    }

    // MARK: Chapter

    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws {
        try dataStore.saveChapter(chapter, storyId: storyId, chapterIndex: chapterIndex)
    }

    func loadChapter(storyId: UUID, chapterIndex: Int) throws -> Chapter {
        try dataStore.loadChapter(storyId: storyId, chapterIndex: chapterIndex)
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
    
    func loadDefinitions(for storyId: UUID) throws -> [Definition] {
        try dataStore.loadDefinitions(for: storyId)
    }

    func saveDefinitions(_ definitions: [Definition]) throws {
        try dataStore.saveDefinitions(definitions)
    }
    
    func saveDefinitions(for storyId: UUID, definitions: [Definition]) throws {
        try dataStore.saveDefinitions(for: storyId, definitions: definitions)
    }

    func deleteDefinitions(for storyId: UUID) throws {
        try dataStore.deleteDefinitions(for: storyId)
    }
    
    func cleanupOrphanedDefinitionFiles() throws {
        try dataStore.cleanupOrphanedDefinitionFiles()
    }

    func loadAppSettings() throws -> SettingsState {
        try dataStore.loadAppSettings()
    }

    func fetchDefinitions(for sentenceIndex: Int,
                          in sentence: Sentence,
                          chapter: Chapter,
                          story: Story,
                          deviceLanguage: Language?) async throws -> [Definition] {
        try await service.fetchDefinitions(for: sentenceIndex,
                                           in: sentence,
                                           chapter: chapter,
                                           story: story,
                                           deviceLanguage: deviceLanguage)
    }

    func purchase(_ product: Product) async throws {
        try await repository.purchase(product)
    }
    
    func validateReceipt() {
        repository.validateAppStoreReceipt()
    }

    func generateImage(with prompt: String) async throws -> Data {
        try await service.generateImage(with: prompt)
    }

    func moderateText(_ text: String) async throws -> ModerationResponse {
        try await service.moderateText(text)
    }

    func enforceChapterCreationLimit(subscription: SubscriptionLevel?) throws {
        try dataStore.trackChapterCreation(subscription: subscription)
    }

}
