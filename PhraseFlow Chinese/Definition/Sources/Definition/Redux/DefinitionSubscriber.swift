//
//  DefinitionSubscriber.swift
//  Definition
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

let definitionSubscriber: OnSubscribe<DefinitionStore, DefinitionEnvironmentProtocol> = { store, environment in

    store
        .subscribe(
            environment.clearDefinitionSubject
        ) { store, _ in
            store.dispatch(.clearCurrentDefinition)
        }
}
