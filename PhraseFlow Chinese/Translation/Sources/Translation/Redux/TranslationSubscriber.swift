//
//  TranslationSubscriber.swift
//  Translation
//
//  Created by Isaac Akalanne on 20/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let translationSubscriber: OnSubscribe<TranslationStore, TranslationEnvironmentProtocol> = { store, environment in
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
