//
//  SettingsEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine
import UserLimit

public struct SettingsEnvironment: SettingsEnvironmentProtocol {
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    public let userLimitEnvironment: UserLimitEnvironmentProtocol
    
    private let settingsDataStore: SettingsDataStoreProtocol
    private let audioEnvironment: AudioEnvironmentProtocol
    
    public init(
        settingsDataStore: SettingsDataStoreProtocol,
        audioEnvironment: AudioEnvironmentProtocol,
        userLimitEnvironment: UserLimitEnvironmentProtocol
    ) {
        self.settingsDataStore = settingsDataStore
        self.audioEnvironment = audioEnvironment
        self.userLimitEnvironment = userLimitEnvironment
        settingsUpdatedSubject = .init(nil)
    }
    
    public var currentVoice: Voice {
        (try? settingsDataStore.loadAppSettings())?.voice ?? .ava
    }
    
    public var speechSpeed: SpeechSpeed {
        (try? settingsDataStore.loadAppSettings())?.speechSpeed ?? .normal
    }
    
    public func saveAppSettings(_ settings: SettingsState) throws {
        audioEnvironment.playSound(.changeSettings)
        try settingsDataStore.saveAppSettings(settings)
        settingsUpdatedSubject.send(settings)
    }
    
    public func loadAppSettings() throws -> SettingsState {
        return try settingsDataStore.loadAppSettings()
    }
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
    
    public func playMusic(_ music: MusicType) throws {
        try audioEnvironment.playMusic(music, volume: .normal)
    }
    
    public func stopMusic() {
        audioEnvironment.stopMusic()
    }
}
