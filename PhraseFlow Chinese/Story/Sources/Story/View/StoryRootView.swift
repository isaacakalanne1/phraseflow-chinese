//
//  StoryRootView.swift
//  Story
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct StoryRootView: View {
    @StateObject private var store: StoryStore
    
    public init(environment: StoryEnvironmentProtocol) {
        self._store = StateObject(wrappedValue: {
            Store(
                initial: StoryState(),
                reducer: storyReducer,
                environment: environment,
                middleware: storyMiddleware,
                subscriber: storySubscriber
            )
        }())
    }
    
    public var body: some View {
        StoryListView()
            .environmentObject(store)
            .onAppear {
                store.dispatch(.loadStories)
            }
    }
}
