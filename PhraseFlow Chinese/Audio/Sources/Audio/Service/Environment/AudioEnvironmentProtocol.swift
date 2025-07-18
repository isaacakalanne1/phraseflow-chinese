//
//  AudioEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import Settings

protocol AudioEnvironmentProtocol {
    var appSoundSubject: CurrentValueSubject<AppSound?, Never> { get }
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var clearDefinitionSubject: CurrentValueSubject<Void, Never> { get }
    
    func playSound(_ sound: AppSound)
    func saveSpeechSpeed(_ speed: SpeechSpeed)
    func clearCurrentDefinition()
}