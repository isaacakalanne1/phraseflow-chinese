//
//  FlowTaleApp.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import AVKit
import SwiftUI
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
import TextGeneration
import TextPractice
import Speech
import ImageGeneration
import Combine

public struct FlowTaleRootView: View {
    private let flowTaleEnvironment: FlowTaleEnvironmentProtocol
    
    public init() {
        let audioEnvironment = AudioEnvironment()
        let snackBarEnvironment = SnackBarEnvironment()
        let userLimitsDataStore = UserLimitsDataStore()
        let settingsDataStore = SettingsDataStore()
        let settingsEnvironment = SettingsEnvironment(
            settingsDataStore: settingsDataStore,
            audioEnvironment: audioEnvironment
        )
        let userLimitEnvironment = UserLimitEnvironment(dataStore: userLimitsDataStore)
        let loadingEnvironment = LoadingEnvironment()
        
        let subscriptionRepository = SubscriptionRepository()
        
        
        let speechRepository = SpeechRepository()
        let speechEnvironment = SpeechEnvironment(speechRepository: speechRepository)
        
        let subscriptionEnvironment = SubscriptionEnvironment(repository: subscriptionRepository,
                                                              speechEnvironment: speechEnvironment,
                                                              settingsEnvironment: settingsEnvironment,
                                                              userLimitsEnvironment: userLimitEnvironment)
        let imageGenerationService = ImageGenerationServices()
        
        
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
        
        let textPracticeEnvironment = TextPracticeEnvironment(audioEnvironment: audioEnvironment,
                                                              settingsEnvironment: settingsEnvironment,
                                                              studyEnvironment: studyEnvironment)

        let translationEnvironment = TranslationEnvironment(
            speechRepository: speechRepository,
            definitionServices: definitionServices,
            definitionDataStore: definitionDataStore,
            audioEnvironment: audioEnvironment,
            settingsEnvironment: settingsEnvironment,
            textPracticeEnvironment: textPracticeEnvironment,
            userLimitEnvironment: userLimitEnvironment
        )
        
        let textGenerationServices = TextGenerationServices()
        let storyDataStore = StoryDataStore()
        let storyEnvironment = StoryEnvironment(
            audioEnvironment: audioEnvironment,
            settingsEnvironment: settingsEnvironment,
            speechEnvironment: speechEnvironment,
            studyEnvironment: studyEnvironment,
            textPracticeEnvironment: textPracticeEnvironment,
            loadingEnvironment: loadingEnvironment,
            userLimitEnvironment: userLimitEnvironment,
            service: textGenerationServices,
            imageGenerationService: imageGenerationService,
            dataStore: storyDataStore
        )
        
        let navigationEnvironment = NavigationEnvironment(
            settingsEnvironment: settingsEnvironment,
            storyEnvironment: storyEnvironment,
            studyEnvironment: studyEnvironment,
            subscriptionEnvironment: subscriptionEnvironment,
            translationEnvironment: translationEnvironment,
            userLimitEnvironment: userLimitEnvironment,
            audioEnvironment: audioEnvironment,
            loadingEnvironment: loadingEnvironment
        )
        
        self.flowTaleEnvironment = FlowTaleEnvironment(
            navigationEnvironment: navigationEnvironment
        )
    }
    
    public var body: some View {
        ContentView(flowTaleEnvironment: flowTaleEnvironment)
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
