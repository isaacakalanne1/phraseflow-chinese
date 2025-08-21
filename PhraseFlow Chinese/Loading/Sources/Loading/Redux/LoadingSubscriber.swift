//
//  LoadingSubscriber.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let loadingSubscriber: OnSubscribe<LoadingStore, LoadingEnvironmentProtocol> = { store, environment in
    environment.loadingStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak store] loadingStatus in
                guard let store else {
                    return
                }
                store.dispatch(.updateLoadingStatus(loadingStatus ?? .none))
            }
            .store(in: &store.subscriptions)
}
