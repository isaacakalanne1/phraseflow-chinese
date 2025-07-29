//
//  StoryDataStore.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Combine
import Foundation
import TextGeneration

enum StoryDataStoreError: Error {
    case failedToCreateUrl
    case failedToSaveData
}

public class StoryDataStore: @preconcurrency StoryDataStoreProtocol {
    public init() {}
    
    private let fileManager = FileManager.default
    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    public let chapterSubject: CurrentValueSubject<Chapter?, Never> = .init(nil)

    private func fileURL(for chapter: Chapter) throws -> URL {
        guard let dir = documentsDirectory else {
            throw StoryDataStoreError.failedToCreateUrl
        }
        let fileName = "\(chapter.id.uuidString).json"
        return dir.appendingPathComponent(fileName)
    }

    public func saveChapter(_ chapter: Chapter) throws {
        let url = try fileURL(for: chapter)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(chapter)
            try data.write(to: url, options: .atomic)
            chapterSubject.send(chapter)
        } catch {
            print("Failed to save chapter: \(error)")
            throw StoryDataStoreError.failedToSaveData
        }
    }

    public func loadAllChapters() throws -> [Chapter] {
        guard let dir = documentsDirectory else {
            throw StoryDataStoreError.failedToCreateUrl
        }
        
        let fileURLs = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        let chapterFileURLs = fileURLs.filter { $0.pathExtension == "json" }

        var chapters: [Chapter] = []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for fileURL in chapterFileURLs {
            if let data = try? Data(contentsOf: fileURL),
               let chapter = try? decoder.decode(Chapter.self, from: data) {
                chapters.append(chapter)
            }
        }

        return chapters.sorted { $0.lastUpdated < $1.lastUpdated }
    }
    
    public func deleteChapter(_ chapter: Chapter) throws {
        let url = try fileURL(for: chapter)
        try fileManager.removeItem(at: url)
    }

    public func loadAllChapters(for storyId: UUID) throws -> [Chapter] {
        let allChapters = try loadAllChapters()
        return allChapters.filter { $0.storyId == storyId }
            .sorted { $0.lastUpdated < $1.lastUpdated }
    }

}
