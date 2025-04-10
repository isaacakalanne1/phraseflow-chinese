//
//  FlowTaleDataStore.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import Security
import Combine

class FlowTaleDataStore: FlowTaleDataStoreProtocol {
    private let fileManager = FileManager.default

    private let kDailyCharacterUsageKey = "dailyCharacterUsageData"
    private let kFreeUserCharacterTotalKey = "freeUserCharacterCount"

    private let keychain = KeychainManager.shared

    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    public let storySubject: CurrentValueSubject<Story?, Never> = .init(nil)
    public let definitionsSubject: CurrentValueSubject<[Definition]?, Never> = .init(nil)

    private func loadDailyCharacterUsage() throws -> [CharacterUsageRecord] {
        guard let data = keychain.getData(forKey: kDailyCharacterUsageKey),
              !data.isEmpty
        else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode([CharacterUsageRecord].self, from: data)
        } catch {
            return []
        }
    }
    
    private func saveDailyCharacterUsage(_ usage: [CharacterUsageRecord]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(usage)
        try keychain.setData(data, forKey: kDailyCharacterUsageKey)
    }

    // MARK: - Free-user total usage in Keychain
    
    private func loadFreeUserCharacterCount() -> Int {
        guard let data = keychain.getData(forKey: kFreeUserCharacterTotalKey),
              !data.isEmpty,
              let stringVal = String(data: data, encoding: .utf8),
              let intVal = Int(stringVal)
        else {
            return 0 // If not found or parse fails, default to 0
        }
        return intVal
    }
    
    private func saveFreeUserCharacterCount(_ count: Int) throws {
        let data = Data("\(count)".utf8)
        try keychain.setData(data, forKey: kFreeUserCharacterTotalKey)
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

    // Helper method to get the file URL for all definitions
    private func definitionsFileURL() -> URL? {
        return documentsDirectory?.appendingPathComponent("definitions.json")
    }

    // Helper method to clean up orphaned definition files
    func cleanupOrphanedDefinitionFiles() throws {
        // Since we're now storing all definitions in a single file,
        // this method is simpler - just check for old format files to delete
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        // Get all old definition files with story ID format
        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)
        let oldDefinitionFiles = contents.filter { $0.hasPrefix("definitions-") && $0.hasSuffix(".json") }

        // Remove all old format files - they should all be migrated to the new format
        for fileName in oldDefinitionFiles {
            let fileURL = dir.appendingPathComponent(fileName)
            try fileManager.removeItem(at: fileURL)
        }

        print("Successfully cleaned up old definition files")
    }

    // MARK: - Sentence Audio Methods

    // Helper method to get the file URL for sentence audio
    private func sentenceAudioFileURL(id: UUID) -> URL? {
        return documentsDirectory?.appendingPathComponent("sentence-audio-\(id.uuidString).m4a")
    }

    // Save sentence audio data
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        guard let fileURL = sentenceAudioFileURL(id: id) else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        do {
            try audioData.write(to: fileURL)
            print("Successfully saved sentence audio: \(id.uuidString)")
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }

    // Load sentence audio data
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

    // Clean up orphaned sentence audio files
    func cleanupOrphanedSentenceAudioFiles() throws {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        // Get all definition files to extract sentenceIds
        let definitions = try loadDefinitions()
        let validSentenceIds = definitions.compactMap { $0.sentenceId.uuidString }

        // Get all sentence audio files
        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)
        let audioFiles = contents.filter { $0.hasPrefix("sentence-audio-") && $0.hasSuffix(".m4a") }

        // Find orphaned audio files
        for fileName in audioFiles {
            // Extract the ID from the filename (sentence-audio-UUID.m4a)
            let idString = fileName.replacingOccurrences(of: "sentence-audio-", with: "")
                .replacingOccurrences(of: ".m4a", with: "")

            // If the ID doesn't exist in our valid IDs, delete the file
            if !validSentenceIds.contains(idString) {
                let fileURL = dir.appendingPathComponent(fileName)
                try fileManager.removeItem(at: fileURL)
            }
        }

        print("Successfully cleaned up orphaned sentence audio files")
    }

    // Load all definitions from the central storage file
    func loadDefinitions() throws -> [Definition] {
        var allDefinitions: [Definition] = []

        // First, check for old-style story-specific definition files to migrate
        try migrateOldFormatDefinitions()

        // Load from the consolidated definitions file
        guard let fileURL = definitionsFileURL() else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        // If the file doesn't exist yet, return an empty array
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            allDefinitions = try decoder.decode([Definition].self, from: data)
            return allDefinitions
        } catch {
            throw FlowTaleDataStoreError.failedToDecodeData
        }
    }

    // Save all definitions to a single file
    func saveDefinitions(_ definitions: [Definition]) throws {
        guard let fileURL = definitionsFileURL() else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let encodedData = try encoder.encode(definitions)
            try encodedData.write(to: fileURL)
            definitionsSubject.send(definitions)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }

    // Delete a specific definition by id
    func deleteDefinition(with id: UUID) throws {
        var definitions = try loadDefinitions()

        // Remove the definition with the specified id
        let initialCount = definitions.count
        definitions.removeAll(where: { $0.id == id })

        if initialCount > definitions.count {
            print("Successfully deleted definition with id: \(id)")
        } else {
            print("No definition found with id: \(id)")
        }

        // Save the updated definitions list
        try saveDefinitions(definitions)
    }

    // Migration helper for old format files
    private func migrateOldFormatDefinitions() throws {
        guard let dir = documentsDirectory else {
            return
        }

        // Get all old-format definition files
        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)
        let oldDefinitionFiles = contents.filter { $0.hasPrefix("definitions-") && $0.hasSuffix(".json") }

        if oldDefinitionFiles.isEmpty {
            // No old files to migrate
            return
        }

        // Load current definitions (if any)
        var allDefinitions: [Definition] = []
        if let fileURL = definitionsFileURL(), fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                allDefinitions = try decoder.decode([Definition].self, from: data)
            } catch {
                // Start with empty if we can't load existing
                allDefinitions = []
            }
        }

        // Process each old file
        for fileName in oldDefinitionFiles {
            let fileURL = dir.appendingPathComponent(fileName)
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let oldDefinitions = try decoder.decode([Definition].self, from: data)

                // Add the old definitions to our consolidated list, avoiding duplicates
                for oldDef in oldDefinitions {
                    // Check if this definition already exists (using timestampData as a unique identifier)
                    if !allDefinitions.contains(where: {
                        $0.timestampData == oldDef.timestampData &&
                            $0.sentence == oldDef.sentence
                    }) {
                        allDefinitions.append(oldDef)
                    }
                }

                // Delete the old file after successful migration
                try fileManager.removeItem(at: fileURL)
            } catch {
                print("Error migrating old definition file \(fileName): \(error)")
                // Continue with other files even if one fails
            }
        }

        // Save the consolidated definitions
        try saveDefinitions(allDefinitions)

        print("Successfully migrated \(oldDefinitionFiles.count) old definition files")
    }

    // ---------------------------------------

    // MARK: - Stories (Main) & Chapters

    // ---------------------------------------
    private func fileURL(for storyId: UUID, chapterIndex: Int) throws -> URL {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let fileName = "\(storyId.uuidString)@\(chapterIndex).json"
        return dir.appendingPathComponent(fileName)
    }

    // Saving & Loading the main Story object
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
            do {
                let data = try Data(contentsOf: fileURL)
                let story = try decoder.decode(Story.self, from: data)
                stories.append(story)
            } catch {
                // Skip files that fail or throw an error—your choice.
            }
        }

        return stories
    }

    // ---------------------------------------

    // MARK: - Saving & Loading individual Chapters

    // ---------------------------------------
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

        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)
        let prefix = storyId.uuidString + "@"

        // We are looking for files like "<storyId>@X.json" with X >= 1
        let chapterFiles = contents
            .filter { $0.hasPrefix(prefix) && $0.hasSuffix(".json") }
            .filter {
                let withoutPrefix = $0.replacingOccurrences(of: prefix, with: "")
                let withoutSuffix = withoutPrefix.replacingOccurrences(of: ".json", with: "")
                if let num = Int(withoutSuffix), num >= 1 {
                    return true
                }
                return false
            }
            .sorted { lhs, rhs in
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

    // MARK: - Remove entire story & chapters

    // ---------------------------------------
    func unsaveStory(_ story: Story) throws {
        let storyId = story.id

        // 1) Remove main story file: "<storyId>@0.json"
        let mainURL = try fileURL(for: storyId, chapterIndex: 0)
        if fileManager.fileExists(atPath: mainURL.path) {
            try fileManager.removeItem(at: mainURL)
        }

        // 2) Remove all chapters
        guard let dir = documentsDirectory else { return }
        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)

        for fileName in contents {
            if fileName.hasPrefix(storyId.uuidString + "@") && fileName.hasSuffix(".json") {
                let fileURL = dir.appendingPathComponent(fileName)
                try fileManager.removeItem(at: fileURL)
            }
        }
    }
}

extension FlowTaleDataStore {
    /// Checks SSML character usage for both free and subscribed users, and logs the usage if allowed.
    /// - Parameters:
    ///   - characterCount: Number of characters in the SSML
    ///   - subscription: The user's current subscription level (nil if free user)
    /// - Throws: `characterLimitReached` or `freeUserCharacterLimitReached` if the user
    ///           cannot create more content.
    func trackSSMLCharacterUsage(characterCount: Int, subscription: SubscriptionLevel?) throws {
        // 1) If subscription == nil => free user
        guard let subscription = subscription else {
            try trackFreeUserCharacterUsage(characterCount)
            return
        }

        // 2) If subscribed => daily usage check
        try trackSubscribedUserCharacterUsage(characterCount, level: subscription)
    }

    /// If user is free (no subscription), total usage is limited to 4000 characters total.
    private func trackFreeUserCharacterUsage(_ characterCount: Int) throws {
        let currentTotal = loadFreeUserCharacterCount()
        #if DEBUG
            let maxFree = 999_999_999_999_999_999
        #else
            let maxFree = 4000
        #endif
        
        // Check if this new usage would exceed the limit
        if currentTotal + characterCount > maxFree {
            throw FlowTaleDataStoreError.freeUserCharacterLimitReached
        }
        
        // Add to the count
        let newCount = currentTotal + characterCount
        try saveFreeUserCharacterCount(newCount)
    }

    // --------------------------------------------------------

    // MARK: - Subscribed User Logic (daily limit)

    // --------------------------------------------------------
    private func trackSubscribedUserCharacterUsage(_ characterCount: Int, level: SubscriptionLevel) throws {
        var usageRecords = try loadDailyCharacterUsage()
        let now = Date()
        let cutoff = now.addingTimeInterval(-24 * 60 * 60)

        // Filter out records older than 24h
        usageRecords = usageRecords.filter { $0.timestamp > cutoff }

        // Calculate total usage in the past 24 hours
        let totalUsage = usageRecords.reduce(0) { $0 + $1.characterCount }
        
        // Check if adding this new usage would exceed the daily limit
        let limit = level.ssmlCharacterLimitPerDay
        if totalUsage + characterCount > limit {
            // The user is at their daily limit => throw an error that includes the time
            // until next character usage is available
            if let earliest = usageRecords.map({ $0.timestamp }).min() {
                let nextAvailableTimeString = timeRemainingStringUntilNextAvailable(earliestTimeStamp: earliest)
                // Attach the localized string to the error
                throw FlowTaleDataStoreError.characterLimitReached(timeUntilNextAvailable: nextAvailableTimeString)
            } else {
                // Fallback (shouldn't happen if totalUsage > 0, but just in case)
                throw FlowTaleDataStoreError.characterLimitReached(timeUntilNextAvailable: "24 hours")
            }
        }

        // Otherwise, log the new usage
        usageRecords.append(CharacterUsageRecord(timestamp: now, characterCount: characterCount))
        try saveDailyCharacterUsage(usageRecords)
    }

    // --------------------------------------------------------

    // MARK: - Time-Remaining Formatter

    // --------------------------------------------------------
    /// Returns a localized string describing how long until the earliest timestamp + 24h from now,
    /// e.g. "23 hours, 59 minutes" or "5 minutes".
    private func timeRemainingStringUntilNextAvailable(earliestTimeStamp: Date) -> String {
        let now = Date()
        let nextAvailable = earliestTimeStamp.addingTimeInterval(24 * 60 * 60)

        let interval = nextAvailable.timeIntervalSince(now)
        guard interval > 0 else {
            // If something is off and the user can already create
            return "Now"
        }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.dropAll]
        formatter.calendar?.locale = .current

        if let formatted = formatter.string(from: interval) {
            return formatted
        } else {
            // Fallback
            return "24 hours"
        }
    }
}
