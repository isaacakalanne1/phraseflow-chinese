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
                          speechSpeed: SpeechSpeed,
                          language: Language) async throws -> ChapterAudio
    func getProducts() async throws -> [Product]
    func generateStory(story: Story) async throws -> String
    func translateStory(story: Story, storyString: String, deviceLanguage: Language?) async throws -> Story
    func loadDefinitions() throws -> [Definition]
    func saveDefinitions(_ definitions: [Definition]) throws
    func loadAppSettings() throws -> SettingsState
    func saveAppSettings(_ settings: SettingsState) throws

    // Stories & Chapters
    func saveStory(_ story: Story) throws
    func loadStory(by id: UUID) throws -> Story
    func loadAllStories() throws -> [Story]
    func deleteStory(_ storyId: UUID) throws

    // Chapters
    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws
    func loadChapter(storyId: UUID, chapterIndex: Int) throws -> Chapter
    func loadAllChapters(for storyId: UUID) throws -> [Chapter]

    func fetchDefinition(of timestampData: WordTimeStampData,
                         withinContextOf sentence: Sentence,
                         story: Story,
                         deviceLanguage: Language?) async throws -> Definition
    func purchase(_ product: Product) async throws
    func generateImage(with prompt: String) async throws -> Data
    func moderateText(_ text: String) async throws -> ModerationResponse
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
                          speechSpeed: SpeechSpeed,
                          language: Language) async throws -> ChapterAudio {
        try await repository.synthesizeSpeech(chapter,
                                              story: story,
                                              voice: voice,
                                              speechSpeed: speechSpeed,
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

    func loadStory(by id: UUID) throws -> Story {
        try dataStore.loadStory(by: id)
    }

    func loadAllStories() throws -> [Story] {
        try dataStore.loadAllStories()
    }

    func deleteStory(_ storyId: UUID) throws {
        try dataStore.deleteStory(storyId)
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

    func saveDefinitions(_ definitions: [Definition]) throws {
        try dataStore.saveDefinitions(definitions)
    }

    func loadAppSettings() throws -> SettingsState {
        try dataStore.loadAppSettings()
    }

    func fetchDefinition(of timestampData: WordTimeStampData,
                         withinContextOf sentence: Sentence,
                         story: Story,
                         deviceLanguage: Language?) async throws -> Definition {
        let definitionString = try await service.fetchDefinition(of: timestampData.word,
                                                                 withinContextOf: sentence,
                                                                 story: story,
                                                                 deviceLanguage: deviceLanguage)
        let definition = Definition(creationDate: .now,
                                    timestampData: timestampData,
                                    sentence: sentence,
                                    definition: definitionString,
                                    language: story.language)
        try dataStore.saveDefinition(definition)
        return definition
    }

    func purchase(_ product: Product) async throws {
        try await repository.purchase(product)
    }

    func generateImage(with prompt: String) async throws -> Data {
        try await service.generateImage(with: prompt)
    }

    func moderateText(_ text: String) async throws -> ModerationResponse {
        try await service.moderateText(text)
    }
}
