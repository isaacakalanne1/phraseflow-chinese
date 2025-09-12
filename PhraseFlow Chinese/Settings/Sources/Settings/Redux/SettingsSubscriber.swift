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
    environment.subscriptionLevelSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] subscriptionLevel in
                guard let store else {
                    return
                }
                store.dispatch(.updateSubscriptionLevel(subscriptionLevel))
            }
            .store(in: &store.subscriptions)
}
