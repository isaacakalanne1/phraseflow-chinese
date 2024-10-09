//
//  FastChineseEnvironment.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import SwiftWhisper

protocol FastChineseEnvironmentProtocol {
    var service: FastChineseServicesProtocol { get }
    var dataStore: FastChineseDataStoreProtocol { get }

    func fetchSpeech(for sentence: Sentence) async throws -> Data
    func generateChapter(using info: ChapterGenerationInfo) async throws -> [Sentence]
    func saveChapter(_ chapter: Chapter) throws
    func unsaveChapter(_ chapter: Chapter)
    func loadChapter(info: ChapterGenerationInfo, chapterIndex: Int) throws -> Chapter
    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL
    func transcribe(audioFrames: [Float]) async throws-> [Segment]

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

    func fetchSpeech(for sentence: Sentence) async throws -> Data {
        try await service.fetchAzureTextToSpeech(sentence: sentence)
    }

    func generateChapter(using info: ChapterGenerationInfo) async throws -> [Sentence] {
        try await service.generateChapter(using: info)
    }

    func saveChapter(_ chapter: Chapter) throws {
        try dataStore.saveChapter(chapter)
    }

    func unsaveChapter(_ chapter: Chapter) {
        dataStore.unsaveChapter(chapter)
    }

    func loadChapter(info: ChapterGenerationInfo, chapterIndex: Int) throws -> Chapter {
        try dataStore.loadChapter(info: info, chapterIndex: chapterIndex)
    }

    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL {
        try dataStore.saveAudioToTempFile(fileName: fileName, data: data)
    }

    func transcribe(audioFrames: [Float]) async throws -> [Segment] {
        try await repository.transcribe(audioFrames: audioFrames)
    }

    func fetchDefinition(of string: String, withinContextOf sentence: String) async throws -> GPTResponse {
        try await service.fetchDefinition(of: string, withinContextOf: sentence)
    }
}
