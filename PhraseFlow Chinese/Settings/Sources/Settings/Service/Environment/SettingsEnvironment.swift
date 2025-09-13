//
//  SettingsEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine

public struct SettingsEnvironment: SettingsEnvironmentProtocol {
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    public var ssmlCharacterCountSubject: CurrentValueSubject<Int?, Never>
    
    private let settingsDataStore: SettingsDataStoreProtocol
    private let audioEnvironment: AudioEnvironmentProtocol
    
    public init(
        settingsDataStore: SettingsDataStoreProtocol,
        audioEnvironment: AudioEnvironmentProtocol
    ) {
        self.settingsDataStore = settingsDataStore
        self.audioEnvironment = audioEnvironment
        settingsUpdatedSubject = .init(nil)
        ssmlCharacterCountSubject = .init(nil)
    }
    
    public func saveAppSettings(_ settings: SettingsState) throws {
        try settingsDataStore.saveAppSettings(settings)
        settingsUpdatedSubject.send(settings)
    }
    
    public func loadAppSettings() throws -> SettingsState {
        let settings = try settingsDataStore.loadAppSettings()
        settingsUpdatedSubject.send(settings)
        return settings
    }
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
    
    public func playMusic(_ music: MusicType) throws {
        try audioEnvironment.playMusic(music, volume: .normal)
    }
    
    public var isPlayingMusic: Bool {
        audioEnvironment.audioPlayer.musicAudioPlayer?.isPlaying ?? false
    }
    
    public func stopMusic() {
        audioEnvironment.stopMusic()
    }
}
