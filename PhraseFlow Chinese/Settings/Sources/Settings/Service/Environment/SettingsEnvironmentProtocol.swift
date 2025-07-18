//
//  SettingsEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

protocol SettingsEnvironmentProtocol {
    var settingsSubject: CurrentValueSubject<Void, Never> { get }
    var speechSpeedSubject: CurrentValueSubject<SpeechSpeed, Never> { get }
    var isPlayingMusicSubject: CurrentValueSubject<Bool, Never> { get }
    var customPromptSubject: CurrentValueSubject<String, Never> { get }
    var storySettingSubject: CurrentValueSubject<StorySetting, Never> { get }
    
    var deviceLanguage: Language? { get }
    var currentVoice: Voice { get }
    var speechSpeed: SpeechSpeed { get }
    
    func saveAppSettings()
    func saveSpeechSpeed(_ speed: SpeechSpeed)
    func setIsPlayingMusic(_ isPlaying: Bool)
    func addCustomPrompt(_ prompt: String)
    func setStorySetting(_ setting: StorySetting)
}