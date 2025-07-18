//
//  ViewStateSubscriber.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

class ViewStateSubscriber {
    static func initialize(store: FlowTaleStore, environment: ViewStateEnvironmentProtocol) {
        
        store.subscribe(environment.isDefiningSubject) { store, isDefining in
            var newViewState = store.state.viewState
            newViewState.isDefining = isDefining
            var newState = store.state
            newState.viewState = newViewState
        }
        
        store.subscribe(environment.loadingStateSubject) { store, loadingState in
            var newViewState = store.state.viewState
            newViewState.loadingState = loadingState
            var newState = store.state
            newState.viewState = newViewState
        }
        
        store.subscribe(environment.isWritingChapterSubject) { store, isWritingChapter in
            var newViewState = store.state.viewState
            newViewState.isWritingChapter = isWritingChapter
            var newState = store.state
            newState.viewState = newViewState
        }
        
        store.subscribe(environment.definitionViewIdSubject) { store, definitionViewId in
            var newViewState = store.state.viewState
            newViewState.definitionViewId = definitionViewId
            var newState = store.state
            newState.viewState = newViewState
        }
    }
}