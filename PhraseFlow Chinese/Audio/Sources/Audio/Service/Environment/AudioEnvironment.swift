//
//  AudioEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import Settings

struct AudioEnvironment: AudioEnvironmentProtocol {
    let appSoundSubject = CurrentValueSubject<AppSound?, Never>(nil)
    let settingsEnvironment: SettingsEnvironmentProtocol
    
    func playSound(_ sound: AppSound) {
        appSoundSubject.send(sound)
    }
    
    func saveSpeechSpeed(_ speed: SpeechSpeed) {
        settingsEnvironment.saveSpeechSpeed(speed)
    }
}