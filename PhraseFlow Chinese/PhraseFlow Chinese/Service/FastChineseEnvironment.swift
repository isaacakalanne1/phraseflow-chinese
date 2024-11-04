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

    func synthesizeSpeech(for chapter: Chapter, voice: Voice) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                               audioData: Data)
    func generateStory(genres: [Genre]) async throws -> Story
    func generateChapter(previousChapter: Chapter) async throws -> ChapterResponse
    func loadStories() throws -> [Story]
    func loadVoice() throws -> Voice
    func saveStory(_ story: Story) throws
    func saveVoice(_ voice: Voice) throws
    func unsaveStory(_ story: Story) throws

    func fetchDefinition(of character: String, withinContextOf sentence: Sentence, shouldForce: Bool) async throws -> Definition
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

    func synthesizeSpeech(for chapter: Chapter, voice: Voice) async throws -> (wordTimestamps: [WordTimeStampData],
                                                                               audioData: Data) {
        try await repository.synthesizeSpeech(chapter.passage, voice: voice)
    }

    func generateStory(genres: [Genre]) async throws -> Story {
        try await service.generateStory(genres: genres)
    }

    func generateChapter(previousChapter: Chapter) async throws -> ChapterResponse {
        try await service.generateChapter(previousChapter: previousChapter)
    }

    func saveStory(_ story: Story) throws {
        try dataStore.saveStory(story)
    }

    func saveVoice(_ voice: Voice) throws {
        try dataStore.saveVoice(voice)
    }

    func unsaveStory(_ story: Story) throws {
        try dataStore.unsaveStory(story)
    }

    func loadStories() throws -> [Story] {
        try dataStore.loadStories()
    }

    func loadVoice() throws -> Voice {
        try dataStore.loadVoice()
    }

    func fetchDefinition(of string: String, withinContextOf sentence: Sentence, shouldForce: Bool) async throws -> Definition {
        if shouldForce {
            let definition = try await service.fetchDefinition(of: string, withinContextOf: sentence)
            return Definition(character: string, sentence: sentence, definition: definition)
        } else if let definition = try? dataStore.loadDefinition(character: string, sentence: sentence) {
            return definition
        } else {
            let definitionString = try await service.fetchDefinition(of: string, withinContextOf: sentence)
            let definition = Definition(character: string, sentence: sentence, definition: definitionString)
            try dataStore.saveDefinition(definition)
            return definition
        }
    }
}
