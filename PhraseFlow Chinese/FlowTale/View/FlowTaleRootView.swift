//
//  FlowTaleRootView.swift
//  FlowTale
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit
import Audio
import Story
import Settings
import Study
import Translation
import Subscription
import SnackBar
import UserLimit
import Moderation
import Navigation
import Loading

public struct FlowTaleRootView: View {
    private let store: FlowTaleStore
    
    public init() {
        let environment = FlowTaleEnvironment(
            audioEnvironment: AudioEnvironment(),
            storyEnvironment: StoryEnvironment(),
            settingsEnvironment: SettingsEnvironment(),
            studyEnvironment: StudyEnvironment(),
            translationEnvironment: TranslationEnvironment(),
            subscriptionEnvironment: SubscriptionEnvironment(),
            snackBarEnvironment: SnackBarEnvironment(),
            userLimitEnvironment: UserLimitEnvironment(),
            moderationEnvironment: ModerationEnvironment(),
            navigationEnvironment: NavigationEnvironment(),
            loadingEnvironment: LoadingEnvironment()
        )
        
        self.store = Store(
            initial: FlowTaleState(),
            reducer: flowTaleReducer,
            environment: environment,
            middleware: flowTaleMiddleware
        )
    }
    
    public var body: some View {
        ContentView()
            .environmentObject(store)
            .onAppear {
                store.dispatch(.loadAppSettings)
                store.dispatch(.storyAction(.loadStoriesAndDefinitions))
                store.dispatch(.subscriptionAction(.fetchSubscriptions))
                store.dispatch(.subscriptionAction(.getCurrentEntitlements))
                store.dispatch(.subscriptionAction(.observeTransactionUpdates))
                store.dispatch(.userLimitAction(.checkFreeTrialLimit))
            }
    }
}