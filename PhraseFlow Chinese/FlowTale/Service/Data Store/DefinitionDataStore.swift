//
//  DefinitionDataStore.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Combine
import Foundation

class DefinitionDataStore: DefinitionDataStoreProtocol {

    private let fileManager = FileManager.default

    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private var definitionsFileURL: URL? {
        documentsDirectory?.appendingPathComponent("definitions.json")
    }

    public let definitionsSubject: CurrentValueSubject<[Definition]?, Never> = .init(nil)

    func cleanupOrphanedDefinitionFiles() throws {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)
        let oldDefinitionFiles = contents.filter { $0.hasPrefix("definitions-") && $0.hasSuffix(".json") }

        for fileName in oldDefinitionFiles {
            let fileURL = dir.appendingPathComponent(fileName)
            try fileManager.removeItem(at: fileURL)
        }

        print("Successfully cleaned up old definition files")
    }

    private func sentenceAudioFileURL(id: UUID) -> URL? {
        return documentsDirectory?.appendingPathComponent("sentence-audio-\(id.uuidString).m4a")
    }

    func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        if let fileURL = sentenceAudioFileURL(id: id) {
            try? audioData.write(to: fileURL)
        }
    }

    func loadSentenceAudio(id: UUID) throws -> Data {
        guard let fileURL = sentenceAudioFileURL(id: id) else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        do {
            return try Data(contentsOf: fileURL)
        } catch {
            throw FlowTaleDataStoreError.failedToDecodeData
        }
    }

    func cleanupOrphanedSentenceAudioFiles() throws {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        let definitions = try loadDefinitions()
        let validSentenceIds = definitions.compactMap { $0.sentenceId.uuidString }

        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)
        let audioFiles = contents.filter { $0.hasPrefix("sentence-audio-") && $0.hasSuffix(".m4a") }

        for fileName in audioFiles {
            let idString = fileName.replacingOccurrences(of: "sentence-audio-", with: "")
                .replacingOccurrences(of: ".m4a", with: "")
            if !validSentenceIds.contains(idString) {
                let fileURL = dir.appendingPathComponent(fileName)
                try fileManager.removeItem(at: fileURL)
            }
        }
    }

    func loadDefinitions() throws -> [Definition] {
        guard let definitionsFileURL,
              fileManager.fileExists(atPath: definitionsFileURL.path),
              let data = try? Data(contentsOf: definitionsFileURL) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Definition].self, from: data)) ?? []
    }

    func saveDefinitions(_ definitions: [Definition]) throws {
        guard let definitionsFileURL else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let encodedData = try encoder.encode(definitions)
            try encodedData.write(to: definitionsFileURL)
            definitionsSubject.send(definitions)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }

    func deleteDefinition(with id: UUID) throws {
        var definitions = try loadDefinitions()
        definitions.removeAll(where: { $0.id == id })
        try saveDefinitions(definitions)
    }
}
