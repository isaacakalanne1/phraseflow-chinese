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

    func fetchSpeech(for phrase: Sentence) async throws -> Data
    func generateChapter(using info: ChapterGenerationInfo) async throws -> [Sentence]
    func saveSentences(_ phrases: [Sentence]) throws
    func unsavePhrase(_ phrase: Sentence)
    func fetchSavedPhrases() throws -> [Sentence]
    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL
    func transcribe(audioFrames: [Float]) async throws-> [Segment]

    func fetchDefinition(of character: String, withinContextOf phrase: String) async throws -> GPTResponse
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

    func fetchSpeech(for sentence: Sentence) async throws -> Data {
        try await service.fetchAzureTextToSpeech(sentence: sentence)
    }

    func generateChapter(using info: ChapterGenerationInfo) async throws -> [Sentence] {
        try await service.generateChapter(using: info)
    }

    func saveSentences(_ phrases: [Sentence]) throws {
        try dataStore.saveSentences(phrases)
    }

    func unsavePhrase(_ phrase: Sentence) {
        dataStore.unsavePhrase(phrase)
    }

    func fetchSavedPhrases() throws -> [Sentence] {
        try dataStore.fetchSavedPhrases()
    }

    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL {
        try dataStore.saveAudioToTempFile(fileName: fileName, data: data)
    }

    func transcribe(audioFrames: [Float]) async throws -> [Segment] {
        try await repository.transcribe(audioFrames: audioFrames)
    }

    func fetchDefinition(of string: String, withinContextOf phrase: String) async throws -> GPTResponse {
        try await service.fetchDefinition(of: string, withinContextOf: phrase)
    }
}
