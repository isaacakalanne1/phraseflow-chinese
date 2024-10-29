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

    func synthesizeSpeech(for chapter: Chapter) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                   audioData: Data)
    func generateStory(categories: [Category]) async throws -> Story
    func generateChapter(previousChapter: Chapter) async throws -> ChapterResponse
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

    func synthesizeSpeech(for chapter: Chapter) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                   audioData: Data) {
        try await repository.synthesizeSpeech(chapter.passage)
    }

    func generateStory(categories: [Category]) async throws -> Story {
        try await service.generateStory(categories: categories)
    }

    func generateChapter(previousChapter: Chapter) async throws -> ChapterResponse {
        try await service.generateChapter(previousChapter: previousChapter)
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
