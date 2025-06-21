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
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var pendingWrites: [UUID: Definition] = [:]
    private var writeWorkItem: DispatchWorkItem?

    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private var definitionsDirectory: URL? {
        documentsDirectory?.appendingPathComponent("definitions")
    }

    public let definitionsSubject: CurrentValueSubject<[Definition]?, Never> = .init(nil)
    
    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        createDefinitionsDirectory()
    }
    
    private func createDefinitionsDirectory() {
        guard let dir = definitionsDirectory else { return }
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    
    private func definitionFileURL(for id: UUID) -> URL? {
        definitionsDirectory?.appendingPathComponent("\(id.uuidString).json")
    }

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

    private func scheduleWrite() {
        writeWorkItem?.cancel()
        writeWorkItem = DispatchWorkItem { [weak self] in
            self?.flushPendingWrites()
        }
        if let workItem = writeWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
        }
    }
    
    private func flushPendingWrites() {
        guard !pendingWrites.isEmpty else { return }
        
        for (id, definition) in pendingWrites {
            guard let fileURL = definitionFileURL(for: id),
                  let data = try? encoder.encode(definition) else { continue }
            print("Saving \(pendingWrites.count) definitions")
            try? data.write(to: fileURL)
        }
        
        pendingWrites.removeAll()
        updateSubject()
    }
    
    private func updateSubject() {
        let definitions = try? loadDefinitions()
        definitionsSubject.send(definitions)
    }

    func loadDefinitions() throws -> [Definition] {
        guard let dir = definitionsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        
        let files = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        
        return jsonFiles.compactMap { fileURL in
            guard let data = try? Data(contentsOf: fileURL),
                  let definition = try? decoder.decode(Definition.self, from: data) else {
                return nil
            }
            return definition
        }
    }

    func saveDefinitions(_ definitions: [Definition]) throws {
        for definition in definitions {
            pendingWrites[definition.id] = definition
        }
        print("Scheduling write for \(definitions.count) definitions")
        scheduleWrite()
    }

    func deleteDefinition(with id: UUID) throws {
        pendingWrites.removeValue(forKey: id)
        guard let fileURL = definitionFileURL(for: id) else { return }
        try? fileManager.removeItem(at: fileURL)
        updateSubject()
    }
}
