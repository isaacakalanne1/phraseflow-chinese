//
//  FlowTaleApp.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI
import AVKit

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
                    store.dispatch(.loadAppSettings)
                    store.dispatch(.loadStories(isAppLaunch: true))
                    store.dispatch(.loadDefinitions)
                    store.dispatch(.fetchSubscriptions)
                    store.dispatch(.getCurrentEntitlements)
                    store.dispatch(.observeTransactionUpdates)
                    store.dispatch(.checkFreeTrialLimit)
                    store.dispatch(.checkDeviceVolumeZero)
                }
        }
    }
}
