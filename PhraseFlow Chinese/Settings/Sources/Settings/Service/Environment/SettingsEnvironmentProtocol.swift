//
//  SettingsEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine
import Moderation

public protocol SettingsEnvironmentProtocol {
    var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> { get }
    
    func saveAppSettings(_ settings: SettingsState) throws
    func loadAppSettings() throws -> SettingsState
    func playSound(_ sound: AppSound)
    func playMusic(_ music: MusicType) throws
    func stopMusic()
    func moderateText(_ text: String) async throws -> ModerationResponse
}
