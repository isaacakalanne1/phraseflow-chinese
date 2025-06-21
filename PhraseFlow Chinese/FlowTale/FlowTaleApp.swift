//
//  FlowTaleApp.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import AVKit
import SwiftUI

@main
struct FlowTaleApp: App {
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
                    UIApplication.shared.isIdleTimerDisabled = true
                    try? AVAudioSession.sharedInstance().setCategory(.playback)
                    store.dispatch(.appSettingsAction(.loadAppSettings))
                    store.dispatch(.storyAction(.loadStories(isAppLaunch: true)))
                    store.dispatch(.subscriptionAction(.fetchSubscriptions))
                    store.dispatch(.subscriptionAction(.getCurrentEntitlements))
                    store.dispatch(.subscriptionAction(.observeTransactionUpdates))
                    store.dispatch(.userLimitAction(.checkFreeTrialLimit))
                }
        }
    }
}
