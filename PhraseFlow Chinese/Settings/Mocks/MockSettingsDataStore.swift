//
//  MockSettingsDataStore.swift
//  Settings
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Settings

enum MockSettingsDataStoreError: Error {
    case genericError
}

public class MockSettingsDataStore: SettingsDataStoreProtocol {
    
    var loadAppSettingsResult: Result<SettingsState, MockSettingsDataStoreError> = .success(.arrange)
    var loadAppSettingsCalled = false
    public func loadAppSettings() throws -> SettingsState {
        loadAppSettingsCalled = true
        switch loadAppSettingsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var saveAppSettingsResult: Result<Void, MockSettingsDataStoreError> = .success(())
    var saveAppSettingsCalled = false
    var saveAppSettingsSpy: SettingsState?
    public func saveAppSettings(_ settings: SettingsState) throws {
        saveAppSettingsSpy = settings
        saveAppSettingsCalled = true
        switch saveAppSettingsResult {
        case .success(let success):
            return
        case .failure(let error):
            throw error
        }
    }
}
