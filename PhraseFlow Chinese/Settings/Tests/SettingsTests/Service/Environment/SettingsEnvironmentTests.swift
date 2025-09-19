//
//  ServiceEnvironmentTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Testing
@testable import Audio
@testable import AudioMocks
@testable import Settings
@testable import SettingsMocks
@testable import Moderation
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
        let expectedSettings = SettingsState.arrange
        try environment.saveAppSettings(expectedSettings)
        
        #expect(mockSettingsDataStore.saveAppSettingsSpy == expectedSettings)
        #expect(mockSettingsDataStore.saveAppSettingsCalled == true)
        #expect(environment.settingsUpdatedSubject.value == expectedSettings)
    }
    
    @Test
    func saveAppSettings_error() throws {
        let expectedSettings = SettingsState.arrange
        mockSettingsDataStore.saveAppSettingsResult = .failure(.genericError)
        do {
            try environment.saveAppSettings(expectedSettings)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockSettingsDataStore.saveAppSettingsSpy == expectedSettings)
            #expect(mockSettingsDataStore.saveAppSettingsCalled == true)
            #expect(environment.settingsUpdatedSubject.value == nil)
        }
    }
    
    @Test
    func loadAppSettings_success() throws {
        let expectedSettings = SettingsState.arrange
        mockSettingsDataStore.loadAppSettingsResult = .success(expectedSettings)
        
        let result = try environment.loadAppSettings()
        
        #expect(result == expectedSettings)
        #expect(mockSettingsDataStore.loadAppSettingsCalled == true)
        #expect(environment.settingsUpdatedSubject.value == expectedSettings)
    }
    
    @Test
    func loadAppSettings_error() throws {
        mockSettingsDataStore.loadAppSettingsResult = .failure(.genericError)
        
        do {
            _ = try environment.loadAppSettings()
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockSettingsDataStore.loadAppSettingsCalled == true)
            #expect(environment.settingsUpdatedSubject.value == nil)
        }
    }
    
    @Test
    func playSound() throws {
        let sound = AppSound.actionButtonPress
        
        environment.playSound(sound)
        
        #expect(mockAudioEnvironment.playSoundSpy == sound)
        #expect(mockAudioEnvironment.playSoundCalled == true)
    }
    
    @Test(arguments: [
        MusicType.whispersOfTranquility,
        MusicType.whispersOfTheForest,
        MusicType.whispersOfTheEnchantedGrove
    ])
    func playMusic_success(music: MusicType) throws {
        try environment.playMusic(music)
        
        #expect(mockAudioEnvironment.playMusicTypeSpy == music)
        #expect(mockAudioEnvironment.playMusicVolumeSpy == .normal)
        #expect(mockAudioEnvironment.playMusicCalled == true)
    }
    
    @Test(arguments: [
        MusicType.whispersOfTranquility,
        MusicType.whispersOfTheForest,
        MusicType.whispersOfTheEnchantedGrove
    ])
    func playMusic_error(music: MusicType) throws {
        mockAudioEnvironment.playMusicResult = .failure(MockAudioEnvironmentError.genericError)
        
        do {
            try environment.playMusic(music)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockAudioEnvironment.playMusicTypeSpy == music)
            #expect(mockAudioEnvironment.playMusicVolumeSpy == .normal)
            #expect(mockAudioEnvironment.playMusicCalled == true)
        }
    }
    
    @Test
    func isPlayingMusic_true() {
        mockAudioEnvironment.isPlayingMusicResult = true
        
        let result = environment.isPlayingMusic
        
        #expect(result == true)
    }
    
    @Test
    func isPlayingMusic_false() {
        mockAudioEnvironment.isPlayingMusicResult = false
        
        let result = environment.isPlayingMusic
        
        #expect(result == false)
    }
    
    @Test
    func stopMusic() {
        environment.stopMusic()
        
        #expect(mockAudioEnvironment.stopMusicCalled == true)
    }
    
    @Test
    func moderateText_success() async throws {
        let text = "Test text to moderate"
        let expectedResponse = ModerationResponse.arrange
        mockModerationEnvironment.moderateTextResult = .success(expectedResponse)
        
        let result = try await environment.moderateText(text)
        
        #expect(result == expectedResponse)
        #expect(mockModerationEnvironment.moderateTextSpy == text)
        #expect(mockModerationEnvironment.moderateTextCalled == true)
    }
    
    @Test
    func moderateText_error() async throws {
        let text = "Test text to moderate"
        mockModerationEnvironment.moderateTextResult = .failure(MockModerationEnvironmentError.genericError)
        
        do {
            _ = try await environment.moderateText(text)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockModerationEnvironment.moderateTextSpy == text)
            #expect(mockModerationEnvironment.moderateTextCalled == true)
        }
    }
}
