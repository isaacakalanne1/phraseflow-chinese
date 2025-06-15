//
//  FlowTaleDataStore.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import Security
import Combine

protocol StoryDataStoreProtocol {
    var storySubject: CurrentValueSubject<Story?, Never> { get }
    func saveStory(_ story: Story) throws
    func loadAllStories() throws -> [Story]
    func unsaveStory(_ story: Story) throws

    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws
    func loadAllChapters(for storyId: UUID) throws -> [Chapter]
}

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

        let contents = try fileManager.contentsOfDirectory(atPath: dir.path)
        let prefix = storyId.uuidString + "@"

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

class FlowTaleDataStore: FlowTaleDataStoreProtocol {
    private let fileManager = FileManager.default

    private let kDailyCharacterUsageKey = "dailyCharacterUsageData"
    private let kFreeUserCharacterTotalKey = "freeUserCharacterCount"

    private let keychain = KeychainManager.shared
    private let storyDataStore = StoryDataStore()

    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    public var storySubject: CurrentValueSubject<Story?, Never> {
        storyDataStore.storySubject
    }
    public let definitionsSubject: CurrentValueSubject<[Definition]?, Never> = .init(nil)

    func saveStory(_ story: Story) throws {
        try storyDataStore.saveStory(story)
    }

    func loadAllStories() throws -> [Story] {
        try storyDataStore.loadAllStories()
    }

    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws {
        try storyDataStore.saveChapter(chapter, storyId: storyId, chapterIndex: chapterIndex)
    }

    func loadAllChapters(for storyId: UUID) throws -> [Chapter] {
        try storyDataStore.loadAllChapters(for: storyId)
    }

    func unsaveStory(_ story: Story) throws {
        try storyDataStore.unsaveStory(story)
    }

    private func loadDailyCharacterUsage() throws -> [CharacterUsageRecord] {
        guard let data = keychain.getData(forKey: kDailyCharacterUsageKey) else {
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

    private func loadFreeUserCharacterCount() -> Int {
        guard let data = keychain.getData(forKey: kFreeUserCharacterTotalKey),
              let stringVal = String(data: data, encoding: .utf8),
              let intVal = Int(stringVal) else {
            return 0
        }
        return intVal
    }
    
    private func saveFreeUserCharacterCount(_ count: Int) throws {
        let data = Data("\(count)".utf8)
        try keychain.setData(data, forKey: kFreeUserCharacterTotalKey)
    }

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

    private var definitionsFileURL: URL? {
        documentsDirectory?.appendingPathComponent("definitions.json")
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
