//
//  SettingsEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import Moderation

public protocol SettingsEnvironmentProtocol {
    var deviceLanguage: Language? { get }
    var currentVoice: Voice { get }
    var speechSpeed: SpeechSpeed { get }
    
    func saveAppSettings(_ settings: SettingsState) throws
    func loadAppSettings() throws -> SettingsState
    func moderateText(_ text: String) async throws -> ModerationResponse
    func playSound(_ sound: AppSound)
    func playMusic(_ music: MusicType)
    func stopMusic()
}
