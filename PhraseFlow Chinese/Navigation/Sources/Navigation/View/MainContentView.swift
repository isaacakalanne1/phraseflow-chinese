//
//  MainContentView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI

public struct MainContentView: View {
    private var store: NavigationStore

    public init() {
        let state = NavigationState()
        let environment = NavigationEnvironment()

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

#Preview {
    MainContentView()
}
