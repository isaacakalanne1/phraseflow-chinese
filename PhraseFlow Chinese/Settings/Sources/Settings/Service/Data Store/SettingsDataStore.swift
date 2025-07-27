//
//  SettingsDataStore.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum SettingsDataStoreError: Error {
    case failedToCreateUrl
    case failedToDecodeData
    case failedToSaveData
}

public class SettingsDataStore: SettingsDataStoreProtocol {
    private var documentsDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    public init() {}

    public func loadAppSettings() throws -> SettingsState {
        guard let fileURL = documentsDirectory?.appendingPathComponent("settingsState.json") else {
            throw SettingsDataStoreError.failedToCreateUrl
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let appSettings = try decoder.decode(SettingsState.self, from: data)
            return appSettings
        } catch {
            throw SettingsDataStoreError.failedToDecodeData
        }
    }

    public func saveAppSettings(_ settings: SettingsState) throws {
        guard let fileURL = documentsDirectory?.appendingPathComponent("settingsState.json") else {
            throw SettingsDataStoreError.failedToCreateUrl
        }
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(settings)
            try encodedData.write(to: fileURL)
        } catch {
            throw SettingsDataStoreError.failedToSaveData
        }
    }
}
