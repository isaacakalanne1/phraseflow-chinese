//
//  FastChineseEnvironment.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

protocol FastChineseEnvironmentProtocol {
    func synthesizeSpeech(for chapter: Chapter, voice: Voice, rate: String, language: Language?, settings: SettingsState) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                                             audioData: Data)
    func generateStory(story: Story?, settings: SettingsState) async throws -> Story
    func loadStories() throws -> [Story]
    func loadAppSettings() throws -> SettingsState
    func saveStory(_ story: Story) throws
    func saveAppSettings(_ settings: SettingsState) throws
    func unsaveStory(_ story: Story) throws

    func fetchDefinition(of character: String, withinContextOf sentence: Sentence, shouldForce: Bool, settings: SettingsState) async throws -> Definition
}

struct FastChineseEnvironment: FastChineseEnvironmentProtocol {

    let service: FastChineseServicesProtocol
    let dataStore: FastChineseDataStoreProtocol
    let repository: FastChineseRepositoryProtocol

    init() {
        self.service = FastChineseServices()
        self.dataStore = FastChineseDataStore()
        self.repository = FastChineseRepository()
    }

    func synthesizeSpeech(for chapter: Chapter, voice: Voice, rate: String, language: Language?, settings: SettingsState) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                                             audioData: Data) {
        try await repository.synthesizeSpeech(chapter, voice: voice, rate: rate, language: language, settings: settings)
    }

    func generateStory(story: Story?, settings: SettingsState) async throws -> Story {
        try await service.generateStory(story: story, settings: settings)
    }

    func saveStory(_ story: Story) throws {
        try dataStore.saveStory(story)
    }

    func saveAppSettings(_ settings: SettingsState) throws {
        try dataStore.saveAppSettings(settings)
    }

    func unsaveStory(_ story: Story) throws {
        try dataStore.unsaveStory(story)
    }

    func loadStories() throws -> [Story] {
        try dataStore.loadStories()
    }

    func loadAppSettings() throws -> SettingsState {
        try dataStore.loadAppSettings()
    }

    func fetchDefinition(of string: String, withinContextOf sentence: Sentence, shouldForce: Bool, settings: SettingsState) async throws -> Definition {
        if shouldForce {
            let definition = try await service.fetchDefinition(of: string, withinContextOf: sentence, settings: settings)
            return Definition(character: string, sentence: sentence, definition: definition)
        } else if let definition = try? dataStore.loadDefinition(character: string, sentence: sentence) {
            return definition
        } else {
            let definitionString = try await service.fetchDefinition(of: string, withinContextOf: sentence, settings: settings)
            let definition = Definition(character: string, sentence: sentence, definition: definitionString)
            try dataStore.saveDefinition(definition)
            return definition
        }
    }
}
