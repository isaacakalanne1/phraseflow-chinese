//
//  MockNavigationEnvironment.swift
//  Navigation
//
//  Created by Isaac Akalanne on 18/09/2025.
//

import Combine
import Navigation
import Settings
import SettingsMocks
import Story
import StoryMocks
import Study
import StudyMocks
import Subscription
import SubscriptionMocks
import Translation
import TranslationMocks
import UserLimit
import UserLimitMocks
import Audio
import AudioMocks
import Loading
import LoadingMocks
import SnackBar
import SnackBarMocks

class MockNavigationEnvironment: NavigationEnvironmentProtocol {
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    
    public var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never>
    
    public let settingsEnvironment: SettingsEnvironmentProtocol
    public let storyEnvironment: StoryEnvironmentProtocol
    public let studyEnvironment: StudyEnvironmentProtocol
    public let subscriptionEnvironment: SubscriptionEnvironmentProtocol
    public let translationEnvironment: TranslationEnvironmentProtocol
    public let userLimitEnvironment: UserLimitEnvironmentProtocol
    public let audioEnvironment: AudioEnvironmentProtocol
    public let snackbarEnvironment: SnackBarEnvironmentProtocol
    public let loadingEnvironment: LoadingEnvironmentProtocol
    
    public init(
        settingsEnvironment: SettingsEnvironmentProtocol = MockSettingsEnvironment(),
        storyEnvironment: StoryEnvironmentProtocol = MockStoryEnvironment(),
        studyEnvironment: StudyEnvironmentProtocol = MockStudyEnvironment(),
        subscriptionEnvironment: SubscriptionEnvironmentProtocol = MockSubscriptionEnvironment(),
        translationEnvironment: TranslationEnvironmentProtocol = MockTranslationEnvironment(),
        userLimitEnvironment: UserLimitEnvironmentProtocol = MockUserLimitEnvironment(),
        audioEnvironment: AudioEnvironmentProtocol = MockAudioEnvironment(),
        snackbarEnvironment: SnackBarEnvironmentProtocol = MockSnackBarEnvironment(),
        loadingEnvironment: LoadingEnvironmentProtocol = MockLoadingEnvironment()
    ) {
        self.settingsEnvironment = settingsEnvironment
        self.storyEnvironment = storyEnvironment
        self.studyEnvironment = studyEnvironment
        self.subscriptionEnvironment = subscriptionEnvironment
        self.translationEnvironment = translationEnvironment
        self.userLimitEnvironment = userLimitEnvironment
        self.audioEnvironment = audioEnvironment
        self.snackbarEnvironment = snackbarEnvironment
        self.loadingEnvironment = loadingEnvironment
        
        self.settingsUpdatedSubject = .init(nil)
        self.limitReachedSubject = .init(.freeLimit)
    }
    
    var playSoundSpy: AppSound?
    var playSoundCalled = false
    public func playSound(_ sound: AppSound) {
        playSoundSpy = sound
        playSoundCalled = true
    }
}
