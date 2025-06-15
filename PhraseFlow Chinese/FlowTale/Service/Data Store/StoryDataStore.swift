//
//  StoryDataStore.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Combine
import Foundation

class StoryDataStore: StoryDataStoreProtocol {
    private let fileManager = FileManager.default
    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    public let storySubject: CurrentValueSubject<Story?, Never> = .init(nil)

    private func fileURL(for storyId: UUID, chapterIndex: Int) throws -> URL {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let fileName = "\(storyId.uuidString)@\(chapterIndex).json"
        return dir.appendingPathComponent(fileName)
    }

    func saveStory(_ story: Story) throws {
        var storyCopy = story
        storyCopy.chapters = []

        let url = try fileURL(for: story.id, chapterIndex: 0)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(storyCopy)
            try data.write(to: url)
            storySubject.send(story)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }

    func loadAllStories() throws -> [Story] {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let files = try fileManager.contentsOfDirectory(atPath: dir.path)
        let storyFiles = files.filter { $0.hasSuffix("@0.json") }

        var stories: [Story] = []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for file in storyFiles {
            let fileURL = dir.appendingPathComponent(file)
            if let data = try? Data(contentsOf: fileURL),
               let story = try? decoder.decode(Story.self, from: data) {
                stories.append(story)
            }
        }

        return stories
    }

    func saveChapter(_ chapter: Chapter,
                     storyId: UUID,
                     chapterIndex: Int) throws
    {
        guard chapterIndex >= 1 else {
            fatalError("Chapter index for saving must be >= 1. The main story is index 0.")
        }

        let url = try fileURL(for: storyId, chapterIndex: chapterIndex)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(chapter)
            try data.write(to: url)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }

    func loadAllChapters(for storyId: UUID) throws -> [Chapter] {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        let prefix = storyId.uuidString + "@"
        let decoder = JSONDecoder()
        
        return try fileManager.contentsOfDirectory(atPath: dir.path)
            .compactMap { fileName -> (String, Int)? in
                guard fileName.hasPrefix(prefix), fileName.hasSuffix(".json"),
                      let index = Int(fileName.dropFirst(prefix.count).dropLast(5)),
                      index >= 1 else { return nil }
                return (fileName, index)
            }
            .sorted { $0.1 < $1.1 }
            .map { fileName, _ in
                let fileURL = dir.appendingPathComponent(fileName)
                let data = try Data(contentsOf: fileURL)
                return try decoder.decode(Chapter.self, from: data)
            }
    }

    func unsaveStory(_ story: Story) throws {
        guard let dir = documentsDirectory,
              let mainURL = try? fileURL(for: story.id, chapterIndex: 0) else {
            return
        }

        if fileManager.fileExists(atPath: mainURL.path) {
            try fileManager.removeItem(at: mainURL)
        }

        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)

        for fileName in contents {
            if fileName.hasPrefix(story.id.uuidString + "@") && fileName.hasSuffix(".json") {
                let fileURL = dir.appendingPathComponent(fileName)
                try fileManager.removeItem(at: fileURL)
            }
        }
    }
}
