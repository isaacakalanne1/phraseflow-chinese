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
import DataStorage
import TextGeneration
import Speech

public struct FlowTaleRootView: View {
    private let store: FlowTaleStore
    
    public init() {
        let audioEnvironment = AudioEnvironment()
        let snackBarEnvironment = SnackBarEnvironment()
        let userLimitEnvironment = UserLimitEnvironment()
        let loadingEnvironment = LoadingEnvironment()
        let subscriptionEnvironment = SubscriptionEnvironment()
        
        let settingsDataStore = SettingsDataStore()
        let settingsEnvironment = SettingsEnvironment(
            settingsDataStore: settingsDataStore,
            audioEnvironment: audioEnvironment
        )
        
        let moderationServices = ModerationServices()
        let moderationDataStore = ModerationDataStore()
        let moderationEnvironment = ModerationEnvironment(
            moderationServices: moderationServices,
            moderationDataStore: moderationDataStore
        )
        
        let definitionServices = DefinitionServices()
        let definitionDataStore = DefinitionDataStore()
        let studyEnvironment = StudyEnvironment(
            definitionServices: definitionServices,
            dataStore: definitionDataStore,
            audioEnvironment: audioEnvironment,
            settingsEnvironment: settingsEnvironment
        )
        
        let speechRepository = SpeechRepository()
        let translationEnvironment = TranslationEnvironment(
            speechRepository: speechRepository,
            definitionServices: definitionServices,
            definitionDataStore: definitionDataStore,
            audioEnvironment: audioEnvironment,
            settingsEnvironment: settingsEnvironment,
            settingsDataStore: settingsDataStore
        )
        
        let textGenerationServices = TextGenerationServices()
        let storyDataStore = StoryDataStore()
        let storyEnvironment = StoryEnvironment(
            audioEnvironment: audioEnvironment,
            settingsEnvironment: settingsEnvironment,
            studyEnvironment: studyEnvironment,
            translationEnvironment: translationEnvironment,
            service: textGenerationServices,
            dataStore: storyDataStore
        )
        
        let navigationEnvironment = NavigationEnvironment(
            storyEnvironment: storyEnvironment,
            audioEnvironment: audioEnvironment
        )
        
        let environment = FlowTaleEnvironment(
            audioEnvironment: audioEnvironment,
            storyEnvironment: storyEnvironment,
            settingsEnvironment: settingsEnvironment,
            studyEnvironment: studyEnvironment,
            translationEnvironment: translationEnvironment,
            subscriptionEnvironment: subscriptionEnvironment,
            snackBarEnvironment: snackBarEnvironment,
            userLimitEnvironment: userLimitEnvironment,
            moderationEnvironment: moderationEnvironment,
            navigationEnvironment: navigationEnvironment,
            loadingEnvironment: loadingEnvironment
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