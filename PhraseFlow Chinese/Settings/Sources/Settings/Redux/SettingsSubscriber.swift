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
}