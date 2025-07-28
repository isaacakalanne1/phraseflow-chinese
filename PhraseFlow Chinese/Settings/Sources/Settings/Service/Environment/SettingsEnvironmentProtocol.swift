//
//  SettingsEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine

public protocol SettingsEnvironmentProtocol {
    var currentVoice: Voice { get }
    var speechSpeed: SpeechSpeed { get }
    
    func saveAppSettings(_ settings: SettingsState) throws
    func loadAppSettings() throws -> SettingsState
    func playSound(_ sound: AppSound)
    func playMusic(_ music: MusicType) throws 
    func stopMusic()
}
