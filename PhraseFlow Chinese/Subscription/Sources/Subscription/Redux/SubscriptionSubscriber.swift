//
//  LoadingSubscriber.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let subscriptionSubscriber: OnSubscribe<SubscriptionStore, SubscriptionEnvironmentProtocol> = { store, environment in

    environment.synthesizedCharactersSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] characterCount in
                guard let store,
                      let characterCount else {
                    return
                }
                store.dispatch(.trackSsmlCharacterCount(characterCount))
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
