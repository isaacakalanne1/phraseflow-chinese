//
//  SettingsEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

public protocol SettingsEnvironmentProtocol {
    var deviceLanguage: Language? { get }
    var currentVoice: Voice { get }
    var speechSpeed: SpeechSpeed { get }
    
    func saveAppSettings(_ settings: SettingsState) throws
    func loadAppSettings() throws -> SettingsState
    func saveSpeechSpeed(_ speed: SpeechSpeed)
    func setIsPlayingMusic(_ isPlaying: Bool)
    func addCustomPrompt(_ prompt: String)
    func setStorySetting(_ setting: StorySetting)
}
