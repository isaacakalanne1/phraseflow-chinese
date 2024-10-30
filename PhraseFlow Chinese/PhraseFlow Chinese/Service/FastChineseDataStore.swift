//
//  FastChineseDataStore.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseDataStoreError: Error {
    case failedToCreateUrl
    case failedToSaveData
    case failedToDecodeData
    case failedToGetDefinition
}

protocol FastChineseDataStoreProtocol {
    func loadStories() throws -> [Story]
    func saveStory(_ story: Story) throws
    func loadDefinitions() throws -> [Definition]
    func loadDefinition(character: String, sentence: Sentence) throws -> Definition
    func saveDefinition(_ definition: Definition) throws
    func unsaveStory(_ story: Story) throws
}

class FastChineseDataStore: FastChineseDataStoreProtocol {

    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    init() {
//        clearData()
    }

    func clearData() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("userData.json")

        // Check if the file exists
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                // Remove the file
                try fileManager.removeItem(at: fileURL)
                print("User data cleared successfully.")
            } catch {
                print("Failed to clear user data: \(error.localizedDescription)")
            }
        } else {
            print("No user data found to clear.")
        }
    }

    func loadStories() throws -> [Story] {
        guard let fileURL = documentsDirectory?.appendingPathComponent("userData.json") else {
            throw FastChineseDataStoreError.failedToCreateUrl
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let stories = try decoder.decode([Story].self, from: data)
            return stories
        } catch {
            throw FastChineseDataStoreError.failedToDecodeData
        }
    }

    func saveStory(_ story: Story) throws {
        var allStories: [Story]
        if let stories = try? loadStories() {
            allStories = stories
            allStories.removeAll(where: { $0.storyOverview == story.storyOverview })
            if allStories.isEmpty {
                allStories = [story]
            } else {
                allStories.append(story)
            }
        } else {
            allStories = [story]
        }

        try saveStories(allStories)
    }

    func loadDefinitions() throws -> [Definition] {
        guard let fileURL = documentsDirectory?.appendingPathComponent("definitions.json") else {
            throw FastChineseDataStoreError.failedToCreateUrl
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let definitions = try decoder.decode([Definition].self, from: data)
            return definitions
        } catch {
            throw FastChineseDataStoreError.failedToDecodeData
        }
    }

    func loadDefinition(character: String, sentence: Sentence) throws -> Definition {
        guard let fileURL = documentsDirectory?.appendingPathComponent("definitions.json") else {
            throw FastChineseDataStoreError.failedToCreateUrl
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let definitions = try decoder.decode([Definition].self, from: data)
            guard let definition = definitions.first(where: { $0.character == character && $0.sentence == sentence }) else {
                throw FastChineseDataStoreError.failedToGetDefinition
            }
            return definition
        } catch {
            throw FastChineseDataStoreError.failedToDecodeData
        }
    }

    func saveDefinition(_ definition: Definition) throws {
        var allDefinitions: [Definition]
        if let definitions = try? loadDefinitions() {
            allDefinitions = definitions
            allDefinitions.removeAll(where: { $0.character == definition.character && $0.sentence == definition.sentence })
            if allDefinitions.isEmpty {
                allDefinitions = [definition]
            } else {
                allDefinitions.append(definition)
            }
        } else {
            allDefinitions = [definition]
        }

        try saveDefinitions(allDefinitions)
    }

    func unsaveStory(_ story: Story) throws {
        if var stories = try? loadStories() {
            stories.removeAll(where: { $0.storyOverview == story.storyOverview })
            try saveStories(stories)
        }
    }

    private func saveStories(_ stories: [Story]) throws {
        guard let fileURL = documentsDirectory?.appendingPathComponent("userData.json") else {
            throw FastChineseDataStoreError.failedToCreateUrl
        }
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(stories)
            try encodedData.write(to: fileURL)
        } catch {
            throw FastChineseDataStoreError.failedToSaveData
        }
    }

    private func saveDefinitions(_ definitions: [Definition]) throws {
        guard let fileURL = documentsDirectory?.appendingPathComponent("definitions.json") else {
            throw FastChineseDataStoreError.failedToCreateUrl
        }
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(definitions)
            try encodedData.write(to: fileURL)
        } catch {
            throw FastChineseDataStoreError.failedToSaveData
        }
    }
}
