//
//  FlowTaleApp.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import AVKit
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

// Temporary types for FlowTaleRootView
struct FlowTaleEnvironment: FlowTaleEnvironmentProtocol {
    let audioEnvironment: AudioEnvironmentProtocol
    let storyEnvironment: StoryEnvironmentProtocol
    let settingsEnvironment: SettingsEnvironmentProtocol
    let studyEnvironment: StudyEnvironmentProtocol
    let translationEnvironment: TranslationEnvironmentProtocol
    let subscriptionEnvironment: SubscriptionEnvironmentProtocol
    let snackBarEnvironment: SnackBarEnvironmentProtocol
    let userLimitEnvironment: UserLimitEnvironmentProtocol
    let moderationEnvironment: ModerationEnvironmentProtocol
    let navigationEnvironment: NavigationEnvironmentProtocol
    let loadingEnvironment: LoadingEnvironmentProtocol
}

func flowTaleReducer(state: FlowTaleState, action: FlowTaleAction) -> FlowTaleState {
    var newState = state
    
    switch action {
    case .audioAction(let audioAction):
        newState.audioState = audioReducer(state: state.audioState, action: audioAction)
    case .storyAction(let storyAction):
        newState.storyState = storyReducer(state: state.storyState, action: storyAction)
    case .settingsAction(let settingsAction):
        newState.settingsState = settingsReducer(state: state.settingsState, action: settingsAction)
    case .studyAction(let studyAction):
        newState.studyState = studyReducer(state: state.studyState, action: studyAction)
    case .translationAction(let translationAction):
        newState.translationState = translationReducer(state: state.translationState, action: translationAction)
    case .subscriptionAction(let subscriptionAction):
        newState.subscriptionState = subscriptionReducer(state: state.subscriptionState, action: subscriptionAction)
    case .snackBarAction(let snackBarAction):
        newState.snackBarState = snackbarReducer(state: state.snackBarState, action: snackBarAction)
    case .userLimitAction(let userLimitAction):
        newState.userLimitState = userLimitReducer(state: state.userLimitState, action: userLimitAction)
    case .moderationAction(let moderationAction):
        newState.moderationState = moderationReducer(state: state.moderationState, action: moderationAction)
    case .navigationAction(let navigationAction):
        newState.navigationState = navigationReducer(state: state.navigationState, action: navigationAction)
    case .loadingAction(let loadingAction):
        newState.loadingState = loadingReducer(state: state.loadingState, action: loadingAction)
    case .viewAction(let viewAction):
        newState.viewState = viewReducer(state: state.viewState, action: viewAction)
    case .loadAppSettings:
        newState.viewState.isInitialisingApp = false
    case .playSound:
        break
    }
    
    return newState
}

func viewReducer(state: ViewState, action: ViewAction) -> ViewState {
    var newState = state
    
    switch action {
    case .setInitializingApp(let value):
        newState.isInitialisingApp = value
    case .setContentTab(let tab):
        newState.contentTab = tab
    case .setSubscriptionSheetShowing(let value):
        newState.isShowingSubscriptionSheet = value
    case .setDailyLimitExplanationShowing(let value):
        newState.isShowingDailyLimitExplanation = value
    case .setFreeLimitExplanationShowing(let value):
        newState.isShowingFreeLimitExplanation = value
    case .setDefining(let value):
        newState.isDefining = value
    case .setWritingChapter(let value):
        newState.isWritingChapter = value
    case .setDefinitionViewId(let id):
        newState.definitionViewId = id
    case .setShowingCustomPromptAlert(let value):
        newState.isShowingCustomPromptAlert = value
    }
    
    return newState
}

func flowTaleMiddleware(state: FlowTaleState, action: FlowTaleAction, environment: FlowTaleEnvironmentProtocol) -> FlowTaleAction? {
    switch action {
    case .audioAction(let audioAction):
        if let nextAction = audioMiddleware(state: state.audioState, action: audioAction, environment: environment.audioEnvironment) {
            return .audioAction(nextAction)
        }
    case .storyAction(let storyAction):
        if let nextAction = storyMiddleware(state: state.storyState, action: storyAction, environment: environment.storyEnvironment) {
            return .storyAction(nextAction)
        }
    case .settingsAction(let settingsAction):
        if let nextAction = settingsMiddleware(state: state.settingsState, action: settingsAction, environment: environment.settingsEnvironment) {
            return .settingsAction(nextAction)
        }
    case .studyAction(let studyAction):
        if let nextAction = studyMiddleware(state: state.studyState, action: studyAction, environment: environment.studyEnvironment) {
            return .studyAction(nextAction)
        }
    case .translationAction(let translationAction):
        if let nextAction = translationMiddleware(state: state.translationState, action: translationAction, environment: environment.translationEnvironment) {
            return .translationAction(nextAction)
        }
    case .subscriptionAction(let subscriptionAction):
        if let nextAction = subscriptionMiddleware(state: state.subscriptionState, action: subscriptionAction, environment: environment.subscriptionEnvironment) {
            return .subscriptionAction(nextAction)
        }
    case .snackBarAction(let snackBarAction):
        if let nextAction = snackbarMiddleware(state: state.snackBarState, action: snackBarAction, environment: environment.snackBarEnvironment) {
            return .snackBarAction(nextAction)
        }
    case .userLimitAction(let userLimitAction):
        if let nextAction = userLimitMiddleware(state: state.userLimitState, action: userLimitAction, environment: environment.userLimitEnvironment) {
            return .userLimitAction(nextAction)
        }
    case .moderationAction(let moderationAction):
        if let nextAction = moderationMiddleware(state: state.moderationState, action: moderationAction, environment: environment.moderationEnvironment) {
            return .moderationAction(nextAction)
        }
    case .navigationAction(let navigationAction):
        if let nextAction = navigationMiddleware(state: state.navigationState, action: navigationAction, environment: environment.navigationEnvironment) {
            return .navigationAction(nextAction)
        }
    case .loadingAction(let loadingAction):
        if let nextAction = loadingMiddleware(state: state.loadingState, action: loadingAction, environment: environment.loadingEnvironment) {
            return .loadingAction(nextAction)
        }
    case .loadAppSettings:
        do {
            let settings = try environment.settingsEnvironment.loadAppSettings()
            return .settingsAction(.onLoadedAppSettings(settings))
        } catch {
            return .settingsAction(.failedToLoadAppSettings)
        }
    case .playSound(let soundEffect):
        switch soundEffect {
        case .progressUpdate:
            environment.audioEnvironment.playSound(.progressUpdate)
        }
    case .viewAction:
        break
    }
    
    return nil
}

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

@main
struct FlowTaleApp: App {

    init() { }

    var body: some Scene {
        WindowGroup {
            FlowTaleRootView()
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    try? AVAudioSession.sharedInstance().setCategory(.playback)
                }
        }
    }
}
