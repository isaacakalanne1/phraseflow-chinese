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
            var newSettings = store.state
            newSettings.isPlayingMusic = isPlaying
            store.dispatch(.onLoadedAppSettings(newSettings))
        }
    
    store
        .subscribe(
            environment.customPromptSubject
        ) { store, prompt in
            guard !prompt.isEmpty else { return }
            var newSettings = store.state
            newSettings.customPrompts.append(prompt)
            store.dispatch(.onLoadedAppSettings(newSettings))
        }
    
    store
        .subscribe(
            environment.storySettingSubject
        ) { store, setting in
            var newSettings = store.state
            newSettings.storySetting = setting
            store.dispatch(.onLoadedAppSettings(newSettings))
        }
}
