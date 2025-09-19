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

class ServiceEnvironmentTests {
    let environment: SettingsEnvironmentProtocol
    
    init() {
        self.environment = SettingsEnvironment(
            settingsDataStore: MockSettingsDataStore(),
            audioEnvironment: MockAudioEnvironment(),
            moderationEnvironment: MockModerationEnvironment()
        )
    }
}
