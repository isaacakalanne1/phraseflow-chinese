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
                          voice: Voice,
                          speechSpeed: SpeechSpeed,
                          language: Language?) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                audioData: Data)
    func getProducts() async throws -> [Product]
    func generateStory(story: Story, deviceLanguage: Language?) async throws -> Story
    func loadStories() throws -> [Story]
    func loadDefinitions() throws -> [Definition]
    func saveDefinitions(_ definitions: [Definition]) throws
    func loadAppSettings() throws -> SettingsState
    func saveStory(_ story: Story) throws
    func saveAppSettings(_ settings: SettingsState) throws
    func unsaveStory(_ story: Story) throws

    func fetchDefinition(of character: String,
                         withinContextOf sentence: Sentence,
                         story: Story,
                         deviceLanguage: Language?) async throws -> Definition
    func purchase(_ product: Product) async throws
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

    func synthesizeSpeech(for chapter: Chapter, voice: Voice, speechSpeed: SpeechSpeed, language: Language?) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                                             audioData: Data) {
        try await repository.synthesizeSpeech(chapter, voice: voice, speechSpeed: speechSpeed, language: language)
    }

    func getProducts() async throws -> [Product] {
        try await repository.getProducts()
    }

    func generateStory(story: Story, deviceLanguage: Language?) async throws -> Story {
        try await service.generateStory(story: story, deviceLanguage: deviceLanguage)
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

    func loadDefinitions() throws -> [Definition] {
        try dataStore.loadDefinitions()
    }

    func saveDefinitions(_ definitions: [Definition]) throws {
        try dataStore.saveDefinitions(definitions)
    }

    func loadAppSettings() throws -> SettingsState {
        try dataStore.loadAppSettings()
    }

    func fetchDefinition(of string: String,
                         withinContextOf sentence: Sentence,
                         story: Story,
                         deviceLanguage: Language?) async throws -> Definition {
        let definitionString = try await service.fetchDefinition(of: string,
                                                                 withinContextOf: sentence,
                                                                 story: story,
                                                                 deviceLanguage: deviceLanguage)
        let definition = Definition(character: string, sentence: sentence, definition: definitionString)
        try dataStore.saveDefinition(definition)
        return definition
    }

    func purchase(_ product: Product) async throws {
        try await repository.purchase(product)
    }
}
