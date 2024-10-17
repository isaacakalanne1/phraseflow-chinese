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
    func generateChapter(using info: Story, chapterIndex: Int, difficulty: Difficulty) async throws -> [Sentence]
    func loadStory(info: StoryGenerationInfo) throws -> Story
    func saveStory(_ story: Story) throws
    func unsaveStory(_ story: Story)

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

    func generateChapter(using story: Story, chapterIndex: Int, difficulty: Difficulty) async throws -> [Sentence] {
        try await service.generateChapter(using: story, chapterIndex: chapterIndex, difficulty: difficulty)
    }

    func saveStory(_ story: Story) throws {
        try dataStore.saveStory(story)
    }

    func unsaveStory(_ story: Story) {
        dataStore.unsaveStory(story)
    }

    func loadStory(info: StoryGenerationInfo) throws -> Story {
        try dataStore.loadStory(info: info)
    }

    func fetchDefinition(of string: String, withinContextOf sentence: String) async throws -> GPTResponse {
        try await service.fetchDefinition(of: string, withinContextOf: sentence)
    }
}
