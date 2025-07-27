//
//  ModerationDataStore.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/07/2025.
//

import Combine
import Foundation

enum ModerationDataStoreError: Error {
    case failedToCreateUrl
    case failedToSaveData
    case failedToDecodeData
}

public class ModerationDataStore: ModerationDataStoreProtocol {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private var moderationDirectory: URL? {
        documentsDirectory?.appendingPathComponent("moderation")
    }
    
    public init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        createModerationDirectory()
    }
    
    private func createModerationDirectory() {
        guard let dir = moderationDirectory else { return }
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    
    private func moderationFileURL(for id: UUID) -> URL? {
        moderationDirectory?.appendingPathComponent("\(id.uuidString).json")
    }
    
    public func saveModerationRecord(_ record: ModerationRecord) throws {
        guard let fileURL = moderationFileURL(for: record.id) else {
            throw ModerationDataStoreError.failedToCreateUrl
        }
        
        do {
            let data = try encoder.encode(record)
            try data.write(to: fileURL)
        } catch {
            throw ModerationDataStoreError.failedToSaveData
        }
    }
    
    public func loadModerationHistory() throws -> [ModerationRecord] {
        guard let dir = moderationDirectory else {
            throw ModerationDataStoreError.failedToCreateUrl
        }
        
        let files = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        
        return jsonFiles.compactMap { fileURL in
            guard let data = try? Data(contentsOf: fileURL),
                  let record = try? decoder.decode(ModerationRecord.self, from: data) else {
                return nil
            }
            return record
        }.sorted { $0.timestamp > $1.timestamp }
    }
    
    public func deleteModerationRecord(id: UUID) throws {
        guard let fileURL = moderationFileURL(for: id) else { return }
        try? fileManager.removeItem(at: fileURL)
    }
    
    public func cleanupOrphanedModerationFiles() throws {
        guard let dir = documentsDirectory else {
            throw ModerationDataStoreError.failedToCreateUrl
        }
        
        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)
        let oldModerationFiles = contents.filter { $0.hasPrefix("moderation-") && $0.hasSuffix(".json") }
        
        for fileName in oldModerationFiles {
            let fileURL = dir.appendingPathComponent(fileName)
            try fileManager.removeItem(at: fileURL)
        }
    }
}