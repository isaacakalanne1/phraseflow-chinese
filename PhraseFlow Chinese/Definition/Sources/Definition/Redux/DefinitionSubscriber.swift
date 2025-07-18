//
//  DefinitionSubscriber.swift
//  Definition
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

class DefinitionSubscriber {
    static func initialize(store: FlowTaleStore, environment: DefinitionEnvironmentProtocol) {
        
        store.subscribe(environment.clearDefinitionSubject) { store, _ in
            store.dispatch(.definitionAction(.clearCurrentDefinition))
        }
    }
}