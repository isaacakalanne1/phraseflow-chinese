//
//  TextPracticeSubscriber.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 04/09/2025.
//

import Foundation
import ReduxKit

@MainActor
let textPracticeSubscriber: OnSubscribe<TextPracticeStore, TextPracticeEnvironmentProtocol> = { store, environment in

    environment.definitionsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] definitions in
                guard let store,
                let definitions,
                      !definitions.isEmpty else {
                    return
                }
                store.dispatch(.addDefinitions(definitions))
            }
            .store(in: &store.subscriptions)

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
