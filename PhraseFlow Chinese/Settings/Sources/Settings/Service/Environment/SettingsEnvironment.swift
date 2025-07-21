//
//  SettingsEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

struct SettingsEnvironment: SettingsEnvironmentProtocol {
    let settingsSubject = CurrentValueSubject<Void, Never>(())
    let speechSpeedSubject = CurrentValueSubject<SpeechSpeed, Never>(.normal)
    let isPlayingMusicSubject = CurrentValueSubject<Bool, Never>(false)
    let customPromptSubject = CurrentValueSubject<String, Never>("")
    let storySettingSubject = CurrentValueSubject<StorySetting, Never>(.random)
    
    private let settingsDataStore: SettingsDataStoreProtocol
    
    init(settingsDataStore: SettingsDataStoreProtocol) {
        self.settingsDataStore = settingsDataStore
    }
    
    init() {
        self.settingsDataStore = SettingsDataStore()
    }
    
    var deviceLanguage: Language? {
        (try? settingsDataStore.loadAppSettings())?.deviceLanguage
    }
    
    var currentVoice: Voice {
        (try? settingsDataStore.loadAppSettings())?.voice ?? .english.voices.first!
    }
    
    var speechSpeed: SpeechSpeed {
        speechSpeedSubject.value
    }
    
    func saveAppSettings(_ settings: SettingsState) throws {
        try settingsDataStore.saveAppSettings(settings)
        settingsSubject.send(())
    }
    
    func loadAppSettings() throws -> SettingsState {
        return try settingsDataStore.loadAppSettings()
    }
    
    func saveSpeechSpeed(_ speed: SpeechSpeed) {
        speechSpeedSubject.send(speed)
    }
    
    func setIsPlayingMusic(_ isPlaying: Bool) {
        isPlayingMusicSubject.send(isPlaying)
    }
    
    func addCustomPrompt(_ prompt: String) {
        customPromptSubject.send(prompt)
    }
    
    func setStorySetting(_ setting: StorySetting) {
        storySettingSubject.send(setting)
    }
}