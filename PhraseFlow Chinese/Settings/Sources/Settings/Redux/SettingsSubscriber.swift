//
//  SettingsSubscriber.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit
import Combine

@MainActor
let settingsSubscriber: OnSubscribe<SettingsStore, SettingsEnvironmentProtocol> = { store, environment in
    environment.settingsUpdatedSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] settings in
                guard let store,
                let settings else {
                    return
                }
                store.dispatch(.refreshAppSettings(settings))
            }
            .store(in: &store.subscriptions)
}
