//
//  StorySubscriber.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let storySubscriber: OnSubscribe<StoryStore, StoryEnvironmentProtocol> = { store, environment in
    
    environment.goToNextChapterSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] _ in
                guard let store else {
                    return
                }
                store.dispatch(.beginGetNextChapter)
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
