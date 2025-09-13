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
    
    environment.ssmlCharacterCountSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] _ in
                guard let store else {
                    return
                }
                store.dispatch(.loadUsageData)
            }
            .store(in: &store.subscriptions)
}
