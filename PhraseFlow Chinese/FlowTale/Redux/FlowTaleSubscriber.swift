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
            environment.dataStore.definitionsSubject
        ) { store, definition in
            if let definition {
                store.dispatch(.definitionAction(.loadDefinitions))
            }
        }

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
}
