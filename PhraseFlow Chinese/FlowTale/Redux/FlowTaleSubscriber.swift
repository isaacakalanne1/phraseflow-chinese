//
//  FlowTaleSubscriber.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import Story
import Settings
import Definition
import SnackBar

// IGNORE: THIS WILL BE DELETED SOON
let flowTaleSubscriber: OnSubscribe<FlowTaleStore, FlowTaleEnvironmentProtocol> = { store, environment in

    store
        .subscribe(
            environment.loadingSubject
        ) { store, loadingState in
            if let loadingState {
                store.dispatch(.storyAction(.updateLoadingStatus(loadingState)))
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

    // Add package subscribers
    storySubscriber(store, environment.storyEnvironment)
    settingsSubscriber(store, environment.settingsEnvironment)
    
    // Add new subscribers
    ViewStateSubscriber.initialize(store: store, environment: environment.viewStateEnvironment)
    SnackBarSubscriber.initialize(store: store, environment: environment.snackBarEnvironment)
    DefinitionSubscriber.initialize(store: store, environment: environment.definitionEnvironment)
    
    // Add cross-package subscribers
    store.subscribe(environment.audioEnvironment.clearDefinitionSubject) { store, _ in
        store.dispatch(.definitionAction(.clearCurrentDefinition))
    }
}
