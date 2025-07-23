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

    init() { }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    try? AVAudioSession.sharedInstance().setCategory(.playback)
                    store.dispatch(.appSettingsAction(.loadAppSettings))
                    store.dispatch(.storyAction(.loadStoriesAndDefinitions))
                    store.dispatch(.subscriptionAction(.fetchSubscriptions))
                    store.dispatch(.subscriptionAction(.getCurrentEntitlements))
                    store.dispatch(.subscriptionAction(.observeTransactionUpdates))
                    store.dispatch(.userLimitAction(.checkFreeTrialLimit))
                }
        }
    }
}
