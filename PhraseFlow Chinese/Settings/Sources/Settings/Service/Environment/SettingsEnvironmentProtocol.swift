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
    func saveAppSettings()
    func saveSpeechSpeed(_ speed: SpeechSpeed)
}