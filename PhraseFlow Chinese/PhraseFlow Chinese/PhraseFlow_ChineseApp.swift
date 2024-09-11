//
//  PhraseFlow_ChineseApp.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

@main
struct PhraseFlow_ChineseApp: App {

    private var store: FastChineseStore

    init() {
        let state = FastChineseState()
        let environment = FastChineseEnvironment()

        store = FastChineseStore(
            initial: state,
            reducer: fastChineseReducer,
            environment: environment,
            middleware: fastChineseMiddleware,
            subscriber: fastChineseSubscriber
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    store.dispatch(.fetchNewPhrases(.short))
                }
        }
    }
}
