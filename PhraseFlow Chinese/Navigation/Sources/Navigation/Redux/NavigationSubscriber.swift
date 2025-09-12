//
//  NavigationSubscriber.swift
//  Navigation
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import ReduxKit
import Story
import Combine

@MainActor
let navigationSubscriber: OnSubscribe<NavigationStore, NavigationEnvironmentProtocol> = { store, environment in
    
    // Listen to Story limit reached events
    environment.userLimitEnvironment.limitReachedSubject
        .receive(on: DispatchQueue.main)
        .sink { [weak store] limitEvent in
            guard let store else { return }
            switch limitEvent {
            case .freeLimit:
                store.dispatch(.showFreeLimitExplanation)
            case .dailyLimit(let nextAvailable):
                store.dispatch(.showDailyLimitExplanation(nextAvailable: nextAvailable))
            }
        }
        .store(in: &store.subscriptions)
    
    // Listen to Translation limit reached events
    environment.translationEnvironment.limitReachedSubject
        .receive(on: DispatchQueue.main)
        .sink { [weak store] limitEvent in
            guard let store else { return }
            switch limitEvent {
            case .freeLimit:
                store.dispatch(.showFreeLimitExplanation)
            case .dailyLimit(let nextAvailable):
                store.dispatch(.showDailyLimitExplanation(nextAvailable: nextAvailable))
            }
        }
        .store(in: &store.subscriptions)
}
