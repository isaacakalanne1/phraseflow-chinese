//
//  SettingsEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine
import UserLimit
import DataStorage

public protocol SettingsEnvironmentProtocol {
    var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> { get }
    var ssmlCharacterCountSubject: CurrentValueSubject<Int?, Never> { get }
    var userLimitEnvironment: UserLimitEnvironmentProtocol { get }
    
    func saveAppSettings(_ settings: SettingsState) throws
    func loadAppSettings() throws -> SettingsState
    func playSound(_ sound: AppSound)
    func playMusic(_ music: MusicType) throws
    var isPlayingMusic: Bool { get }
    func stopMusic()
}
