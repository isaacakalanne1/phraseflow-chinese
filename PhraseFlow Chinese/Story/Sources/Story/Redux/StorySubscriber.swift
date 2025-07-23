//
//  StorySubscriber.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

let storySubscriber: OnSubscribe<StoryStore, StoryEnvironmentProtocol> = { store, environment in
    store
        .subscribe(
            environment.storySubject
        ) { store, storyId in
            if let storyId = storyId {
                store.dispatch(.storyAction(.selectChapter(storyId: storyId)))
            }
        }
}
