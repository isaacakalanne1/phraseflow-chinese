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
}

protocol FlowTaleDataStoreProtocol {
    func loadStories() throws -> [Story]
    func loadAppSettings() throws -> SettingsState
    func saveStory(_ story: Story) throws
    func saveAppSettings(_ settings: SettingsState) throws
    func loadDefinitions() throws -> [Definition]
    func saveDefinition(_ definition: Definition) throws
    func saveDefinitions(_ definitions: [Definition]) throws
    func unsaveStory(_ story: Story) throws
}

class FlowTaleDataStore: FlowTaleDataStoreProtocol {

    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    init() {
//        clearData(path: "userData.json")
//        clearData(path: "settingsState.json")
    }

    func clearData(path: String) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(path)

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

    func loadStories() throws -> [Story] {
        guard let fileURL = documentsDirectory?.appendingPathComponent("userData.json") else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let stories = try decoder.decode([Story].self, from: data)
            return stories
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

    func saveStory(_ story: Story) throws {
        var allStories: [Story]
        if let stories = try? loadStories() {
            allStories = stories
            allStories.removeAll(where: { $0.id == story.id })
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
            stories.removeAll(where: { $0.id == story.id })
            try saveStories(stories)
        }
    }

    private func saveStories(_ stories: [Story]) throws {
        guard let fileURL = documentsDirectory?.appendingPathComponent("userData.json") else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(stories) // TODO: Improve this code, to avoid running out of memory. Possibly save stories one at a time, rather than all stories at once
            try encodedData.write(to: fileURL)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }

    func saveDefinitions(_ definitions: [Definition]) throws {
        guard let fileURL = documentsDirectory?.appendingPathComponent("definitions.json") else {
            throw FlowTaleDataStoreError.failedToCreateUrl
        }
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(definitions)
            try encodedData.write(to: fileURL)
        } catch {
            throw FlowTaleDataStoreError.failedToSaveData
        }
    }
}
