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
    store
        .subscribe(
            environment.storySubject
        ) { store, storyId in
            if let storyId = storyId {
                store.dispatch(.selectChapter(storyId: storyId))
            }
        }
}
