//
//  SettingsSubscriber.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let settingsSubscriber: OnSubscribe<SettingsStore, SettingsEnvironmentProtocol> = { store, environment in
    
    store
        .subscribe(
            environment.settingsSubject
        ) { store, _ in
            store.dispatch(.saveAppSettings)
        }
    
    store
        .subscribe(
            environment.speechSpeedSubject
        ) { store, speed in
            store.dispatch(.updateSpeechSpeed(speed))
        }
    
    store
        .subscribe(
            environment.isPlayingMusicSubject
        ) { store, isPlaying in
            var newSettingsState = store.state.settingsState
            newSettingsState.isPlayingMusic = isPlaying
            store.dispatch(.onLoadedAppSettings(newSettingsState))
        }
    
    store
        .subscribe(
            environment.customPromptSubject
        ) { store, prompt in
            guard !prompt.isEmpty else { return }
            var newSettingsState = store.state.settingsState
            newSettingsState.customPrompts.append(prompt)
            store.dispatch(.onLoadedAppSettings(newSettingsState))
        }
    
    store
        .subscribe(
            environment.storySettingSubject
        ) { store, setting in
            var newSettingsState = store.state.settingsState
            newSettingsState.storySetting = setting
            store.dispatch(.onLoadedAppSettings(newSettingsState))
        }
}
