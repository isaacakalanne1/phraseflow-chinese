//
//  DefinitionDataStore.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Combine
import Foundation
import TextGeneration

enum DefinitionDataStoreError: Error {
    case failedToCreateUrl
    case failedToDecodeData
}

public class DefinitionDataStore: DefinitionDataStoreProtocol {

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var pendingWrites: [UUID: Definition] = [:]
    private var writeTimer: Timer?

    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private var definitionsDirectory: URL? {
        documentsDirectory?.appendingPathComponent("definitions")
    }
    
    public init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        createDefinitionsDirectory()
        scheduleWrite()
    }
    
    deinit {
        writeTimer?.invalidate()
    }
    
    private func createDefinitionsDirectory() {
        guard let dir = definitionsDirectory else { return }
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    
    private func definitionFileURL(for id: UUID) -> URL? {
        definitionsDirectory?.appendingPathComponent("\(id.uuidString).json")
    }
    
    public func cleanupDefinitionsNotInChapters(_ chapters: [Chapter]) throws {
        print("Starting cleanup of definitions not matching chapter story IDs...")
        
        // Get all current definitions
        let definitions = try loadDefinitions()
        
        // Collect valid story IDs from chapters
        let validStoryIds = Set(chapters.map { $0.storyId })
        
        // Find definitions to delete (those with story IDs not in chapters)
        let definitionsToDelete = definitions.filter { definition in
            !validStoryIds.contains(definition.storyId) && !definition.hasBeenSeen
        }
        
        print("Found \(definitionsToDelete.count) definitions to delete (out of \(definitions.count) total definitions)")
        
        // Delete all orphaned definitions in batch
        for definition in definitionsToDelete {
            try deleteDefinition(with: definition.id)
        }
        
        print("Successfully deleted \(definitionsToDelete.count) definitions with mismatched story IDs")
    }

    private func sentenceAudioFileURL(id: UUID) -> URL? {
        return documentsDirectory?.appendingPathComponent("sentence-audio-\(id.uuidString).m4a")
    }

    public func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        if let fileURL = sentenceAudioFileURL(id: id) {
            try? audioData.write(to: fileURL)
        }
    }

    public func loadSentenceAudio(id: UUID) throws -> Data {
        guard let fileURL = sentenceAudioFileURL(id: id) else {
            throw DefinitionDataStoreError.failedToCreateUrl
        }

        do {
            return try Data(contentsOf: fileURL)
        } catch {
            throw DefinitionDataStoreError.failedToDecodeData
        }
    }

    private func scheduleWrite() {
        writeTimer?.invalidate()
        writeTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.flushPendingWrites()
        }
    }
    
    private func flushPendingWrites() {
        print("Saving \(pendingWrites.count) definitions")
        for (id, definition) in pendingWrites {
            guard let fileURL = definitionFileURL(for: id),
                  let data = try? encoder.encode(definition) else { continue }
            try? data.write(to: fileURL)
        }
        
        pendingWrites.removeAll()
        scheduleWrite()
    }

    public func loadDefinitions() throws -> [Definition] {
        guard let dir = definitionsDirectory else {
            throw DefinitionDataStoreError.failedToCreateUrl
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

    public func saveDefinitions(_ definitions: [Definition]) throws {
        for definition in definitions {
            pendingWrites[definition.id] = definition
        }
        print("Scheduling write for \(definitions.count) definitions")
    }

    public func deleteDefinition(with id: UUID) throws {
        pendingWrites.removeValue(forKey: id)
        guard let fileURL = definitionFileURL(for: id) else { return }
        try? fileManager.removeItem(at: fileURL)
    }
}
