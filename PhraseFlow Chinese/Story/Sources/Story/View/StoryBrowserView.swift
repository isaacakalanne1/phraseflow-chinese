//
//  StoryBrowserView.swift
//  Story
//
//  Created by Assistant on 23/07/2025.
//

import SwiftUI
import ReduxKit

public struct StoryBrowserView: View {
    private var store: StoryStore
    
    public init() {
        let state = StoryState()
        let environment = StoryEnvironment()
        
        store = StoryStore(
            initial: state,
            reducer: { state, action in
                return state
            },
            environment: environment,
            middleware: storyMiddleware
        )
    }
    
    public var body: some View {
        StoryListView()
            .environmentObject(store)
    }
}