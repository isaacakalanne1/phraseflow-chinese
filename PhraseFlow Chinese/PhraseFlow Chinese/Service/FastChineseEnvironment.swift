//
//  FastChineseEnvironment.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

protocol FastChineseEnvironmentProtocol {
    var service: FastChineseServicesProtocol { get }
    var dataStore: FastChineseDataStoreProtocol { get }

    func synthesizeSpeech(for sentence: Sentence) async throws -> (wordTimestamps: [(word: String,
                                                                                     time: Double,
                                                                                     textOffset: Int,
                                                                                     wordLength: Int)],
                                                                   audioData: Data)
    func generateStory(categories: [Category]) async throws -> Story
    func generateChapter(using info: Story) async throws -> [Sentence]
    func loadStories() throws -> [Story]
    func saveStory(_ story: Story) throws
    func unsaveStory(_ story: Story) throws

    func fetchDefinition(of character: String, withinContextOf sentence: String) async throws -> GPTResponse
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

    func synthesizeSpeech(for sentence: Sentence) async throws -> (wordTimestamps: [(word: String,
                                                                                     time: Double,
                                                                                     textOffset: Int,
                                                                                     wordLength: Int)],
                                                                   audioData: Data) {
        try await repository.synthesizeSpeech(sentence.mandarin)
    }

    func generateStory(categories: [Category]) async throws -> Story {
        try await service.generateStory(categories: categories)
    }

    func generateChapter(using story: Story) async throws -> [Sentence] {
        try await service.generateChapter(using: story)
    }

    func saveStory(_ story: Story) throws {
        try dataStore.saveStory(story)
    }

    func unsaveStory(_ story: Story) throws {
        try dataStore.unsaveStory(story)
    }

    func loadStories() throws -> [Story] {
        try dataStore.loadStories()
    }

    func fetchDefinition(of string: String, withinContextOf sentence: String) async throws -> GPTResponse {
        try await service.fetchDefinition(of: string, withinContextOf: sentence)
    }
}
