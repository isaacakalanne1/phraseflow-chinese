//
//  MockSettingsEnvironment.swift
//  Settings
//
//  Created by Isaac Akalanne on 18/09/2025.
//

import Combine
import Audio
import AudioMocks
import Settings
import Moderation
import ModerationMocks

enum MockSettingsEnvironmentError: Error {
    case genericError
}

public class MockSettingsEnvironment: SettingsEnvironmentProtocol {
    public var audioEnvironment: AudioEnvironmentProtocol
    
    public var settingsUpdatedSubject: CurrentValueSubject<Settings.SettingsState?, Never> = .init(nil)
    
    public init(audioEnvironment: AudioEnvironmentProtocol = MockAudioEnvironment()) {
        self.audioEnvironment = audioEnvironment
    }
    
    var saveAppSettingsSpy: SettingsState? = nil
    var saveAppSettingsCalled = false
    var saveAppSettingsResult: Result<Void, MockSettingsEnvironmentError> = .success(())
    public func saveAppSettings(_ settings: SettingsState) throws {
        saveAppSettingsSpy = settings
        saveAppSettingsCalled = true
        switch saveAppSettingsResult {
        case .success:
            break
        case .failure(let error):
            throw error
        }
    }
    
    var loadAppSettingsCalled = false
    var loadAppSettingsResult: Result<SettingsState, MockSettingsEnvironmentError> = .success(.arrange)
    public func loadAppSettings() throws -> SettingsState {
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
    public func playSound(_ sound: AppSound) {
        playSoundSpy = sound
        playSoundCalled = true
    }
    
    var playMusicSpy: MusicType? = nil
    var playMusicCalled = false
    var playMusicResult: Result<Void, MockSettingsEnvironmentError> = .success(())
    public func playMusic(_ music: MusicType) throws {
        playMusicSpy = music
        playMusicCalled = true
        switch playMusicResult {
        case .success:
            break
        case .failure(let error):
            throw error
        }
    }
    
    
    public var isPlayingMusic: Bool = false
    
    var stopMusicCalled = false
    public func stopMusic() {
        stopMusicCalled = true
    }
    
    var moderateTextSpy = ""
    var moderateTextCalled = false
    var moderateTextResult: Result<ModerationResponse, MockSettingsEnvironmentError> = .success(.arrange)
    public func moderateText(_ text: String) async throws -> ModerationResponse {
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
