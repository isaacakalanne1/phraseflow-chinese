//
//  ServiceEnvironmentTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Testing
import AudioMocks
@testable import Settings
@testable import SettingsMocks
@testable import ModerationMocks

class SettingsEnvironmentTests {
    let environment: SettingsEnvironmentProtocol
    let mockSettingsDataStore: MockSettingsDataStore
    let mockAudioEnvironment: MockAudioEnvironment
    let mockModerationEnvironment: MockModerationEnvironment
    
    init() {
        self.mockSettingsDataStore = MockSettingsDataStore()
        self.mockAudioEnvironment = MockAudioEnvironment()
        self.mockModerationEnvironment = MockModerationEnvironment()

        self.environment = SettingsEnvironment(
            settingsDataStore: mockSettingsDataStore,
            audioEnvironment: mockAudioEnvironment,
            moderationEnvironment: mockModerationEnvironment
        )
    }
    
    @Test
    func saveAppSettings_success() throws {
        // Given
        let expectedSettings = SettingsState.arrange
        // When
        try environment.saveAppSettings(expectedSettings)
        
        // Then
        #expect(mockSettingsDataStore.saveAppSettingsSpy == expectedSettings)
        #expect(mockSettingsDataStore.saveAppSettingsCalled == true)
        #expect(environment.settingsUpdatedSubject.value == expectedSettings)
    }
    
    @Test
    func saveAppSettings_error() throws {
        // Given
        let expectedSettings = SettingsState.arrange
        mockSettingsDataStore.saveAppSettingsResult = .failure(.genericError)
        // When
        do {
            try environment.saveAppSettings(expectedSettings)
            Issue.record("Should have thrown an error")
        } catch {
            // Then
            #expect(mockSettingsDataStore.saveAppSettingsSpy == expectedSettings)
            #expect(mockSettingsDataStore.saveAppSettingsCalled == true)
            #expect(environment.settingsUpdatedSubject.value == nil)
        }
    }
}
