//
//  StoryRootView.swift
//  Story
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct StoryRootView: View {
    private let store: StoryStore
    
    public init(environment: StoryEnvironmentProtocol) {
        self.store = Store(
            initial: StoryState(),
            reducer: storyReducer,
            environment: environment,
            middleware: storyMiddleware,
            subscriber: storySubscriber
        )
        store.dispatch(.loadStoriesAndDefinitions)
    }
    
    public var body: some View {
        StoryListView()
            .environmentObject(store)
    }
}
