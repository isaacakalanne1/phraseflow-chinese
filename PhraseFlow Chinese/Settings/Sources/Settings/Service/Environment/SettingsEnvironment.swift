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
    public let settingsUpdatedSubject = CurrentValueSubject<Void, Never>(())
    let speechSpeedSubject = CurrentValueSubject<SpeechSpeed, Never>(.normal)
    let isPlayingMusicSubject = CurrentValueSubject<Bool, Never>(false)
    let storySettingSubject = CurrentValueSubject<StorySetting, Never>(.random)
    
    private let settingsDataStore: SettingsDataStoreProtocol
    private let audioEnvironment: AudioEnvironmentProtocol
    
    public init(
        settingsDataStore: SettingsDataStoreProtocol,
        audioEnvironment: AudioEnvironmentProtocol
    ) {
        self.settingsDataStore = settingsDataStore
        self.audioEnvironment = audioEnvironment
    }
    
    public var deviceLanguage: Language? {
        (try? settingsDataStore.loadAppSettings())?.language.deviceLanguage
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
        settingsUpdatedSubject.send(())
    }
    
    public func loadAppSettings() throws -> SettingsState {
        return try settingsDataStore.loadAppSettings()
    }
    
    func updateSpeechSpeed(_ newSpeed: SpeechSpeed) throws {
        playSound(.togglePress)
        var settings = try loadAppSettings()
        settings.speechSpeed = newSpeed
        try saveAppSettings(settings)
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
