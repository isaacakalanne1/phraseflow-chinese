//
//  NavigationSubscriber.swift
//  Navigation
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import ReduxKit
import Combine

@MainActor
let navigationSubscriber: OnSubscribe<NavigationStore, NavigationEnvironmentProtocol> = { store, environment in
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
