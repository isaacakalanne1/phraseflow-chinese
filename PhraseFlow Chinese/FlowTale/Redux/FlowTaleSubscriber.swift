//
//  FlowTaleSubscriber.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit

let flowTaleSubscriber: OnSubscribe<FlowTaleStore, FlowTaleEnvironmentProtocol> = { store, environment in

    store
        .subscribe(
            environment.dataStore.storySubject
        ) { store, story in
            if let story {
                store.dispatch(.storyAction(.loadStories(isAppLaunch: false)))
            }
        }

    store
        .subscribe(
            environment.dataStore.definitionsSubject
        ) { store, definition in
            if let definition {
                store.dispatch(.loadDefinitions)
            }
        }

    store
        .subscribe(
            environment.loadingSubject
        ) { store, loadingState in
            if let loadingState {
                store.dispatch(.updateLoadingState(loadingState))
            }
        }
}
