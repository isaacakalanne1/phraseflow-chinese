//
//  FlowTaleDataStore.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FlowTaleDataStoreError: Error {
    case failedToCreateUrl
    case failedToSaveData
    case failedToDecodeData
    case storyNotFound
    case chapterNotFound
}

// MARK: - Protocol

protocol FlowTaleDataStoreProtocol {
    // Settings
    func loadAppSettings() throws -> SettingsState
    func saveAppSettings(_ settings: SettingsState) throws

    // Definitions
    func loadDefinitions() throws -> [Definition]
    func saveDefinition(_ definition: Definition) throws
    func saveDefinitions(_ definitions: [Definition]) throws

    // Stories & Chapters
    func saveStory(_ story: Story) throws
    func loadStory(by id: UUID) throws -> Story
    func loadAllStories() throws -> [Story]
    func deleteStory(_ storyId: UUID) throws

    // Chapters
    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws
    func loadChapter(storyId: UUID, chapterIndex: Int) throws -> Chapter
    func loadAllChapters(for storyId: UUID) throws -> [Chapter]

    // Remove entire story (and its chapters) from disk
    func unsaveStory(_ story: Story) throws
}

// MARK: - Implementation

class FlowTaleDataStore: FlowTaleDataStoreProtocol {

    private let fileManager = FileManager.default

    /// Documents directory URL
    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    // ---------------------------------------
    // MARK: - App Settings
    // ---------------------------------------

    func loadAppSettings() throws -> SettingsState {
        guard let fileURL = documentsDirectory?.appendingPathComponent("settingsState.json") else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let appSettings = try decoder.decode(SettingsState.self, from: data)
            return appSettings
        } catch {
            throw FlowTaleDataStoreError.failedToDecodeData
        }
    }

    func saveAppSettings(_ settings: SettingsState) throws {
        guard let fileURL = documentsDirectory?.appendingPathComponent("settingsState.json") else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(settings)
            try encodedData.write(to: fileURL)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }

    // ---------------------------------------
    // MARK: - Definitions
    // ---------------------------------------

    func loadDefinitions() throws -> [Definition] {
        guard let fileURL = documentsDirectory?.appendingPathComponent("definitions.json") else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let definitions = try decoder.decode([Definition].self, from: data)
            return definitions
        } catch {
            throw FlowTaleDataStoreError.failedToDecodeData
        }
    }

    func saveDefinition(_ definition: Definition) throws {
        var allDefinitions = (try? loadDefinitions()) ?? []
        if let index = allDefinitions.firstIndex(where: { $0.timestampData.id == definition.timestampData.id }) {
            allDefinitions[index] = definition
        } else {
            allDefinitions.append(definition)
        }
        try saveDefinitions(allDefinitions)
    }

    func saveDefinitions(_ definitions: [Definition]) throws {
        guard let fileURL = documentsDirectory?.appendingPathComponent("definitions.json") else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let encoder = JSONEncoder()
        do {
            // Shuffle or not, depending on your preference
            let encodedData = try encoder.encode(definitions.shuffled())
            try encodedData.write(to: fileURL)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }

    // ---------------------------------------
    // MARK: - Stories (Main) & Chapters
    // ---------------------------------------

    /// Helper to build a file URL for a given storyId & index.
    /// - parameter storyId: The UUID of the story
    /// - parameter chapterIndex: 0 for the main `Story`, 1..n for chapters
    private func fileURL(for storyId: UUID, chapterIndex: Int) throws -> URL {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let fileName = "\(storyId.uuidString)@\(chapterIndex).json"
        return dir.appendingPathComponent(fileName)
    }

    // ---------------------------------------
    // Saving & Loading the main Story object
    // ---------------------------------------

    /// Saves the main `Story` under "<storyId>@0.json".
    /// This example strips out chapters to avoid duplication, but you can adapt as needed.
    func saveStory(_ story: Story) throws {
        // By default, store all fields but remove the chapters array to reduce duplication.
        // You can store them if you prefer, but they will also be saved individually below.
        var storyCopy = story

        let url = try fileURL(for: story.id, chapterIndex: 0)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(storyCopy)
            try data.write(to: url)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }

        // Optionally, if you want to automatically save all chapters too:
        // for (index, chapter) in story.chapters.enumerated() {
        //     try saveChapter(chapter, storyId: story.id, chapterIndex: index + 1)
        // }
    }

    /// Loads the main `Story` by ID from "<storyId>@0.json".
    func loadStory(by id: UUID) throws -> Story {
        let url = try fileURL(for: id, chapterIndex: 0)
        guard fileManager.fileExists(atPath: url.path) else {
            throw FlowTaleDataStoreError.storyNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let story = try decoder.decode(Story.self, from: data)
            return story
        } catch {
            throw FlowTaleDataStoreError.failedToDecodeData
        }
    }

    /// Loads **all** stories by scanning for filenames that match "@0.json" in the documents folder.
    func loadAllStories() throws -> [Story] {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let files = try fileManager.contentsOfDirectory(atPath: dir.path)

        // Filter to only files that contain "@0.json"
        let storyFiles = files.filter { $0.hasSuffix("@0.json") }

        var stories: [Story] = []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for file in storyFiles {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let data = try Data(contentsOf: fileURL)
                let story = try decoder.decode(Story.self, from: data)
                stories.append(story)
            } catch {
                // You could either throw or just skip files that fail
                // throw FlowTaleDataStoreError.failedToDecodeData
            }
        }

        return stories
    }

    /// Deletes just the main story file. Does NOT remove chapters.
    func deleteStory(_ storyId: UUID) throws {
        let url = try fileURL(for: storyId, chapterIndex: 0)
        guard fileManager.fileExists(atPath: url.path) else {
            throw FlowTaleDataStoreError.storyNotFound
        }
        try fileManager.removeItem(at: url)
    }

    // ---------------------------------------
    // Saving & Loading individual Chapters
    // ---------------------------------------

    /// Saves a single chapter under "<storyId>@(chapterIndex).json" (where chapterIndex >= 1).
    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws {
        // Typically 1..N for the chapters
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

    /// Loads a single chapter from "<storyId>@(chapterIndex).json".
    func loadChapter(storyId: UUID, chapterIndex: Int) throws -> Chapter {
        let url = try fileURL(for: storyId, chapterIndex: chapterIndex)
        guard fileManager.fileExists(atPath: url.path) else {
            throw FlowTaleDataStoreError.chapterNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        do {
            let chapter = try decoder.decode(Chapter.self, from: data)
            return chapter
        } catch {
            throw FlowTaleDataStoreError.failedToDecodeData
        }
    }

    /// Loads **all** chapters for the given story ID by scanning filenames `<storyId>@1.json`, `<storyId>@2.json`, etc.
    func loadAllChapters(for storyId: UUID) throws -> [Chapter] {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)

        // We are looking for files that match: "<storyId>@X.json" with X >= 1
        let prefix = storyId.uuidString + "@"
        let chapterFiles = contents
            .filter { $0.hasPrefix(prefix) && $0.hasSuffix(".json") }
            .filter {
                // Extract the part after '@' and before '.json'
                // e.g. "UUID@3.json" => "3"
                // Then ensure it's an Int >= 1
                let withoutPrefix = $0.replacingOccurrences(of: prefix, with: "")
                let withoutSuffix = withoutPrefix.replacingOccurrences(of: ".json", with: "")
                if let num = Int(withoutSuffix), num >= 1 {
                    return true
                }
                return false
            }
            .sorted { lhs, rhs in
                // Sort by chapter index ascending
                // Extract numeric part and compare
                let leftIdx = Int(
                    lhs.split(separator: "@")
                       .last?
                       .replacingOccurrences(of: ".json", with: "")
                    ?? ""
                ) ?? 0

                let rightIdx = Int(
                    rhs.split(separator: "@")
                       .last?
                       .replacingOccurrences(of: ".json", with: "")
                    ?? ""
                ) ?? 0

                return leftIdx < rightIdx
            }

        var chapters: [Chapter] = []
        let decoder = JSONDecoder()

        for fileName in chapterFiles {
            let fileURL = dir.appendingPathComponent(fileName)
            let data = try Data(contentsOf: fileURL)
            let chapter = try decoder.decode(Chapter.self, from: data)
            chapters.append(chapter)
        }

        return chapters
    }

    // ---------------------------------------
    // Remove entire story & chapters
    // ---------------------------------------

    func unsaveStory(_ story: Story) throws {
        let storyId = story.id

        // 1) Remove main story file: "<storyId>@0.json"
        let mainURL = try fileURL(for: storyId, chapterIndex: 0)
        if fileManager.fileExists(atPath: mainURL.path) {
            try fileManager.removeItem(at: mainURL)
        }

        // 2) Remove all chapters: "<storyId>@1.json", "<storyId>@2.json", etc.
        guard let dir = documentsDirectory else { return }
        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)

        for fileName in contents {
            if fileName.hasPrefix(storyId.uuidString + "@") && fileName.hasSuffix(".json") {
                let fileURL = dir.appendingPathComponent(fileName)
                try fileManager.removeItem(at: fileURL)
            }
        }
    }

    // ---------------------------------------
    // Example helper to clear data
    // ---------------------------------------

    func clearData(path: String) {
        guard let documentsDirectory = documentsDirectory else {
            return
        }
        let fileURL = documentsDirectory.appendingPathComponent(path)

        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                print("Data at \(path) cleared successfully.")
            } catch {
                print("Failed to clear data at \(path): \(error.localizedDescription)")
            }
        } else {
            print("No data found at \(path) to clear.")
        }
    }
}
