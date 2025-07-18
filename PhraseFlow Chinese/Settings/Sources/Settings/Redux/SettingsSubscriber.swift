//
//  SettingsSubscriber.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

let settingsSubscriber: OnSubscribe<FlowTaleStore, SettingsEnvironmentProtocol> = { store, environment in
    
    store
        .subscribe(
            environment.settingsSubject
        ) { store, _ in
            store.dispatch(.appSettingsAction(.saveAppSettings))
        }
    
    store
        .subscribe(
            environment.speechSpeedSubject
        ) { store, speed in
            store.dispatch(.appSettingsAction(.updateSpeechSpeed(speed)))
        }
    
    store
        .subscribe(
            environment.isPlayingMusicSubject
        ) { store, isPlaying in
            var newState = store.state
            newState.settingsState.isPlayingMusic = isPlaying
        }
    
    store
        .subscribe(
            environment.customPromptSubject
        ) { store, prompt in
            guard !prompt.isEmpty else { return }
            var newState = store.state
            newState.settingsState.customPrompts.append(prompt)
        }
    
    store
        .subscribe(
            environment.storySettingSubject
        ) { store, setting in
            var newState = store.state
            newState.settingsState.storySetting = setting
        }
}