//
//  SettingsEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine
import Moderation

public struct SettingsEnvironment: SettingsEnvironmentProtocol {
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    
    private let settingsDataStore: SettingsDataStoreProtocol
    private let audioEnvironment: AudioEnvironmentProtocol
    private let moderationEnvironment: ModerationEnvironmentProtocol
    
    public init(
        settingsDataStore: SettingsDataStoreProtocol,
        audioEnvironment: AudioEnvironmentProtocol,
        moderationEnvironment: ModerationEnvironmentProtocol
    ) {
        self.settingsDataStore = settingsDataStore
        self.audioEnvironment = audioEnvironment
        self.moderationEnvironment = moderationEnvironment
        settingsUpdatedSubject = .init(nil)
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
        audioEnvironment.isPlayingMusic
    }
    
    public func stopMusic() {
        audioEnvironment.stopMusic()
    }
    
    public func moderateText(_ text: String) async throws -> ModerationResponse {
        return try await moderationEnvironment.moderateText(text)
    }
}
