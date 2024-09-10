//
//  FastChineseEnvironment.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import SwiftWhisper

protocol FastChineseEnvironmentProtocol {
    var service: FastChineseServicesProtocol { get }
    var dataStore: FastChineseDataStoreProtocol { get }

    func fetchSpeech(for phrase: Phrase) async throws -> Data
    func fetchPhrases(category: PhraseCategory) async throws -> [Phrase]
    func saveAllPhrases(_ phrases: [Phrase]) throws
    func clearLearningPhrases(category: PhraseCategory)
    func fetchSavedPhrases() throws -> [Phrase]
    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL
    func transcribe(audioFrames: [Float]) async throws-> [Segment]
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

    func fetchSpeech(for phrase: Phrase) async throws -> Data {
        try await service.fetchAzureTextToSpeech(phrase: phrase)
    }

    func fetchPhrases(category: PhraseCategory) async throws -> [Phrase] {
        try await service.fetchPhrases(category: category)
    }

    func saveAllPhrases(_ phrases: [Phrase]) throws {
        try dataStore.saveAllPhrases(phrases)
    }

    func fetchSavedPhrases() throws -> [Phrase] {
        try dataStore.fetchSavedPhrases()
    }

    func clearLearningPhrases(category: PhraseCategory) {
        dataStore.clearLearningPhrases(category: category)
    }

    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL {
        try dataStore.saveAudioToTempFile(fileName: fileName, data: data)
    }

    func transcribe(audioFrames: [Float]) async throws -> [Segment] {
        try await repository.transcribe(audioFrames: audioFrames)
    }
}
