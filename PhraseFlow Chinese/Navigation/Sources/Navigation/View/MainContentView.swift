//
//  MainContentView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI

public struct MainContentView: View {
    private var store: NavigationStore

    public init(environment: NavigationEnvironmentProtocol) {
        let state = NavigationState()

        store = NavigationStore(
            initial: state,
            reducer: navigationReducer,
            environment: environment,
            middleware: navigationMiddleware,
            subscriber: navigationSubscriber
        )
    }
    
    public var body: some View {
        VStack {
            DisplayedContentView()
            TabBarView()
        }
        .environmentObject(store)
    }
}

// #Preview {
//     MainContentView(environment: NavigationEnvironment(
//         storyEnvironment: MockStoryEnvironment(),
//         audioEnvironment: MockAudioEnvironment()
//     ))
// }
