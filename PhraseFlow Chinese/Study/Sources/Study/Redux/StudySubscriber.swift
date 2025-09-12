//
//  StudySubscriber.swift
//  Study
//
//  Created by Isaac Akalanne on 22/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let studySubscriber: OnSubscribe<StudyStore, StudyEnvironmentProtocol> = { store, environment in
    environment.definitionsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] definitions in
                guard let store,
                      let definitions else {
                    return
                }
                store.dispatch(.addDefinitions(definitions))
            }
            .store(in: &store.subscriptions)
    
    environment.settingsUpdatedSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] settings in
                guard let store,
                let settings else {
                    return
                }
                store.dispatch(.refreshAppSettings(settings))
            }
            .store(in: &store.subscriptions)
}
