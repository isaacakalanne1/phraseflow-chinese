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
    
    environment.limitReachedSubject
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
