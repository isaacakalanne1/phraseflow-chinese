//
//  FlowTaleSubscriber.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import Story

let flowTaleSubscriber: OnSubscribe<FlowTaleStore, FlowTaleEnvironmentProtocol> = { store, environment in

    store
        .subscribe(
            environment.loadingSubject
        ) { store, loadingState in
            if let loadingState {
                store.dispatch(.storyAction(.updateLoadingState(loadingState)))
            }
        }

    store
        .subscribe(
            environment.chapterSubject
        ) { store, chapter in
            if let chapter {
                store.dispatch(.storyAction(.saveChapter(chapter)))
            }
        }

    // Add story subscriber
    storySubscriber(store, environment.storyEnvironment)
}
