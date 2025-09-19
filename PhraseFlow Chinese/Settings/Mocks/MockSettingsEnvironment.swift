//
//  MockSettingsEnvironment.swift
//  Settings
//
//  Created by Isaac Akalanne on 18/09/2025.
//

import Combine
import Audio
import Settings
import Moderation
import ModerationMocks

enum MockSettingsEnvironmentError: Error {
    case genericError
}

class MockSettingsEnvironment: SettingsEnvironmentProtocol {
    var settingsUpdatedSubject: CurrentValueSubject<Settings.SettingsState?, Never> = .init(nil)
    
    var saveAppSettingsSpy: SettingsState? = nil
    var saveAppSettingsCalled = false
    var saveAppSettingsResult: Result<Void, MockSettingsEnvironmentError> = .success(())
    func saveAppSettings(_ settings: SettingsState) throws {
        saveAppSettingsSpy = settings
        saveAppSettingsCalled = true
        switch saveAppSettingsResult {
        case .success(let success):
            break
        case .failure(let error):
            throw error
        }
    }
    
    var loadAppSettingsCalled = false
    var loadAppSettingsResult: Result<SettingsState, MockSettingsEnvironmentError> = .success(.arrange)
    func loadAppSettings() throws -> SettingsState {
        loadAppSettingsCalled = true
        switch loadAppSettingsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var playSoundSpy: AppSound? = nil
    var playSoundCalled = false
    func playSound(_ sound: AppSound) {
        playSoundSpy = sound
        playSoundCalled = true
    }
    
    var playMusicSpy: MusicType? = nil
    var playMusicCalled = false
    var playMusicResult: Result<Void, MockSettingsEnvironmentError> = .success(())
    func playMusic(_ music: MusicType) throws {
        playMusicSpy = music
        playMusicCalled = true
        switch playMusicResult {
        case .success(let success):
            break
        case .failure(let error):
            throw error
        }
    }
    
    
    var isPlayingMusic: Bool = false
    
    var stopMusicCalled = false
    func stopMusic() {
        stopMusicCalled = true
    }
    
    var moderateTextSpy = ""
    var moderateTextCalled = false
    var moderateTextResult: Result<ModerationResponse, MockSettingsEnvironmentError> = .success(.arrange)
    func moderateText(_ text: String) async throws -> ModerationResponse {
        moderateTextSpy = text
        moderateTextCalled = true
        switch moderateTextResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}
