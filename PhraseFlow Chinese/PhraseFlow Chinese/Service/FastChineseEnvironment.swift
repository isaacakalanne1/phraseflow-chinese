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
    func fetchAllPhrases(gid: String) async throws -> [Phrase]
    func fetchLearningPhrases(category: PhraseCategory) -> [Phrase]
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

    func fetchAllPhrases(gid: String) async throws -> [Phrase] {
        try await service.fetchAllPhrases(gid: gid)
    }

    func fetchLearningPhrases(category: PhraseCategory) -> [Phrase] {
        dataStore.fetchLearningPhrases(category: category)
    }

    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL {
        try dataStore.saveAudioToTempFile(fileName: fileName, data: data)
    }

    func transcribe(audioFrames: [Float]) async throws -> [Segment] {
        try await repository.transcribe(audioFrames: audioFrames)
    }
}
