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
    
    func saveAppSettings() {
        settingsSubject.send(())
    }
    
    func saveSpeechSpeed(_ speed: SpeechSpeed) {
        speechSpeedSubject.send(speed)
    }
}