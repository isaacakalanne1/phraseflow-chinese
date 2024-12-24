//
//  PhraseFlow_ChineseApp.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

@main
struct PhraseFlow_ChineseApp: App {

    private var store: FlowTaleStore

    init() {

        let state = FlowTaleState()
        let environment = FlowTaleEnvironment()

        store = FlowTaleStore(
            initial: state,
            reducer: flowTaleReducer,
            environment: environment,
            middleware: flowTaleMiddleware,
            subscriber: flowTaleSubscriber
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    store.dispatch(.loadStories)
                    store.dispatch(.loadDefinitions)
                    store.dispatch(.loadAppSettings)
                    store.dispatch(.fetchSubscriptions)
                }
        }
    }
}
