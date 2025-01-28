//
//  FlowTaleDataStore.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import Security

enum FlowTaleDataStoreError: Error {
    case failedToCreateUrl
    case failedToSaveData
    case failedToDecodeData
    case storyNotFound
    case chapterNotFound
    // New: free user overall limit
    case freeUserChapterLimitReached
    case chapterCreationLimitReached(timeUntilNextAvailable: String)
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
    func deleteDefinitions(for storyId: UUID) throws

    // Stories & Chapters
    func saveStory(_ story: Story) throws
    func loadStory(by id: UUID) throws -> Story
    func loadAllStories() throws -> [Story]

    // Chapters
    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws
    func loadChapter(storyId: UUID, chapterIndex: Int) throws -> Chapter
    func loadAllChapters(for storyId: UUID) throws -> [Chapter]

    // Remove entire story (and its chapters) from disk
    func unsaveStory(_ story: Story) throws

    func trackChapterCreation(subscription: SubscriptionLevel?) throws
}

final class KeychainManager {

    static let shared = KeychainManager()

    private init() {}

    // Store data in keychain
    func setData(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String:            kSecClassGenericPassword,
            kSecAttrAccount as String:      key,
            kSecValueData as String:        data
        ]

        // Remove any existing item first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    // Retrieve data from keychain
    func getData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String:            kSecClassGenericPassword,
            kSecAttrAccount as String:      key,
            kSecReturnData as String:       true,
            kSecMatchLimit as String:       kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    // You can also expose a helper for removing items by key
    func removeValue(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String:        kSecClassGenericPassword,
            kSecAttrAccount as String:  key
        ]
        SecItemDelete(query as CFDictionary)
    }

    // Basic error
    enum KeychainError: Error {
        case unhandledError(status: OSStatus)
    }
}


class FlowTaleDataStore: FlowTaleDataStoreProtocol {

    private let fileManager = FileManager.default

    // Keychain keys
    private let kDailyCreationKey = "dailyChapterCreationTimestamps"
    private let kFreeUserTotalKey = "freeUserChapterCount"

    // We'll use this reference:
    private let keychain = KeychainManager.shared

    /// Filename used to track chapter-creation timestamps
    private let chapterCreationLogFilename = "chapterCreationLog.json"

    /// Documents directory URL
    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    // MARK: - Daily usage in Keychain
    private func loadDailyCreationDates() throws -> [Date] {
        guard let data = keychain.getData(forKey: kDailyCreationKey),
              !data.isEmpty else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode([Date].self, from: data)
        } catch {
            return []
        }
    }

    private func saveDailyCreationDates(_ dates: [Date]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(dates)
        try keychain.setData(data, forKey: kDailyCreationKey)
    }

    // MARK: - Free-user total usage in Keychain
    private func loadFreeUserChapterCount() -> Int {
        guard let data = keychain.getData(forKey: kFreeUserTotalKey),
              !data.isEmpty,
              let stringVal = String(data: data, encoding: .utf8),
              let intVal = Int(stringVal) else {
            return 0 // If not found or parse fails, default to 0
        }
        return intVal
    }

    private func saveFreeUserChapterCount(_ count: Int) throws {
        let data = Data("\(count)".utf8)
        try keychain.setData(data, forKey: kFreeUserTotalKey)
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

    func deleteDefinitions(for storyId: UUID) throws {
        let currentDefinitions = try loadDefinitions()
        let filteredDefinitions = currentDefinitions.filter {
            $0.timestampData.storyId != storyId
        }
        try saveDefinitions(filteredDefinitions)
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
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }

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
    // MARK: - Daily Chapter-Creation Tracking
    // ---------------------------------------
    /// Loads the creation dates from disk.
    private func loadChapterCreationDates() throws -> [Date] {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let fileURL = dir.appendingPathComponent(chapterCreationLogFilename)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            // If no file yet, return empty
            return []
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode([Date].self, from: data)
        } catch {
            // If decoding fails for any reason, you can decide to discard or throw
            return []
        }
    }

    /// Saves the creation dates back to disk.
    private func saveChapterCreationDates(_ dates: [Date]) throws {
        guard let dir = documentsDirectory else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let fileURL = dir.appendingPathComponent(chapterCreationLogFilename)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(dates)
            try data.write(to: fileURL)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
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

    func loadChapter(storyId: UUID, chapterIndex: Int) throws -> Chapter {
        let url = try fileURL(for: storyId, chapterIndex: chapterIndex + 1)
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

extension FlowTaleDataStore {
    /// Checks usage for both free and subscribed users, and logs a new creation if allowed.
    /// - Parameter subscription: The user's current subscription level (nil if free user).
    /// - Throws: `chapterCreationLimitReached` or `freeUserChapterLimitReached` if the user
    ///           cannot create more chapters.
    func trackChapterCreation(subscription: SubscriptionLevel?) throws {

        // 1) If subscription == nil => free user
        guard let subscription = subscription else {
            try trackFreeUserCreation()
            return
        }

        // 2) If subscribed => daily usage check
        try trackSubscribedUserCreation(level: subscription)
    }

    /// If user is free (no subscription), total usage is limited to 4 chapters total.
    private func trackFreeUserCreation() throws {
        let currentCount = loadFreeUserChapterCount()
        let maxFree = 4
        if currentCount >= maxFree {
            throw FlowTaleDataStoreError.freeUserChapterLimitReached
        }
        // increment
        let newCount = currentCount + 1
        try saveFreeUserChapterCount(newCount)
    }

    // --------------------------------------------------------
    // MARK: - Subscribed User Logic (daily limit)
    // --------------------------------------------------------
    private func trackSubscribedUserCreation(level: SubscriptionLevel) throws {
        var creationDates = try loadDailyCreationDates()
        let now = Date()
        let cutoff = now.addingTimeInterval(-24 * 60 * 60)

        // Filter out timestamps older than 24h
        creationDates = creationDates.filter { $0 > cutoff }

        // Check limit
        let limit = level.chapterLimitPerDay
        if creationDates.count >= limit {
            // The user is at their daily limit => throw an error that includes the time
            // until next creation is available.
            if let earliest = creationDates.min() {
                let nextAvailableTimeString = timeRemainingStringUntilNextChapter(earliestCreationDate: earliest)
                // Attach the localized string to the error
                throw FlowTaleDataStoreError.chapterCreationLimitReached(timeUntilNextAvailable: nextAvailableTimeString)
            } else {
                // Fallback (shouldn't happen if .count >= limit, but just in case)
                throw FlowTaleDataStoreError.chapterCreationLimitReached(timeUntilNextAvailable: "24 hours")
            }
        }

        // Otherwise, log a new creation
        creationDates.append(now)
        try saveDailyCreationDates(creationDates)
    }

    // --------------------------------------------------------
    // MARK: - Time-Remaining Formatter
    // --------------------------------------------------------
    /// Returns a localized string describing how long until earliestCreationDate + 24h from now,
    /// e.g. "23 hours, 59 minutes" or "5 minutes".
    private func timeRemainingStringUntilNextChapter(earliestCreationDate: Date) -> String {
        let now = Date()
        let nextAvailable = earliestCreationDate.addingTimeInterval(24 * 60 * 60)

        let interval = nextAvailable.timeIntervalSince(now)
        guard interval > 0 else {
            // If something is off and the user can already create
            return "Now"
        }

        let formatter = DateComponentsFormatter()
        // .full => "2 hours, 5 minutes, 30 seconds"
        // .abbreviated => "2h 5m 30s"
        // .short => "2 hr, 5 min, 30 sec"
        // .spellOut => "two hours, five minutes..."
        formatter.unitsStyle = .full

        // Choose which units you want to display
        // e.g. days, hours, minutes, seconds
        formatter.allowedUnits = [.day, .hour, .minute, .second]

        // Remove any zero-value components
        formatter.zeroFormattingBehavior = [.dropAll]

        // If you want up to 2 components only, e.g. "22 hours, 30 minutes", then do:
        // formatter.maximumUnitCount = 2
        // But let's show them all.

        // Set the locale if you want to ensure correct language
        formatter.calendar?.locale = .current

        if let formatted = formatter.string(from: interval) {
            return formatted
        } else {
            // Fallback
            return "24 hours"
        }
    }
}
