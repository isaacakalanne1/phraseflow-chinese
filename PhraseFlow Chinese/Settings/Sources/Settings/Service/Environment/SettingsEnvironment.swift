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
import DataStorage

public struct SettingsEnvironment: SettingsEnvironmentProtocol {
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    public var ssmlCharacterCountSubject: CurrentValueSubject<Int?, Never>
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
