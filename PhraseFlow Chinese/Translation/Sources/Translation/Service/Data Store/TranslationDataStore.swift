//
//  TranslationDataStore.swift
//  Translation
//
//  Created by Isaac Akalanne on 20/07/2025.
//

import Combine
import Foundation
import TextGeneration

enum TranslationDataStoreError: Error {
    case failedToCreateUrl
    case failedToSaveData
    case failedToDecodeData
}

class TranslationDataStore: TranslationDataStoreProtocol {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private var translationsDirectory: URL? {
        documentsDirectory?.appendingPathComponent("translations")
    }
    
    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        createTranslationsDirectory()
    }
    
    private func createTranslationsDirectory() {
        guard let dir = translationsDirectory else { return }
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    
    private func translationFileURL(for id: UUID) -> URL? {
        translationsDirectory?.appendingPathComponent("\(id.uuidString).json")
    }
    
    func saveTranslation(_ chapter: Chapter) throws {
        guard let fileURL = translationFileURL(for: chapter.id) else {
            throw TranslationDataStoreError.failedToCreateUrl
        }
        
        do {
            let data = try encoder.encode(chapter)
            try data.write(to: fileURL)
        } catch {
            throw TranslationDataStoreError.failedToSaveData
        }
    }
    
    func loadTranslationHistory() throws -> [Chapter] {
        guard let dir = translationsDirectory else {
            throw TranslationDataStoreError.failedToCreateUrl
        }
        
        let files = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        
        return jsonFiles.compactMap { fileURL in
            guard let data = try? Data(contentsOf: fileURL),
                  let chapter = try? decoder.decode(Chapter.self, from: data) else {
                return nil
            }
            return chapter
        }
    }
    
    func deleteTranslation(id: UUID) throws {
        guard let fileURL = translationFileURL(for: id) else { return }
        try? fileManager.removeItem(at: fileURL)
    }
    
    func cleanupOrphanedTranslationFiles() throws {
        guard let dir = documentsDirectory else {
            throw TranslationDataStoreError.failedToCreateUrl
        }
        
        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)
        let oldTranslationFiles = contents.filter { $0.hasPrefix("translations-") && $0.hasSuffix(".json") }
        
        for fileName in oldTranslationFiles {
            let fileURL = dir.appendingPathComponent(fileName)
            try fileManager.removeItem(at: fileURL)
        }
    }
}