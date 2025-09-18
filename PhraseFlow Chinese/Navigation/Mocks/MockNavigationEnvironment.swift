//
//  MockNavigationEnvironment.swift
//  Navigation
//
//  Created by Isaac Akalanne on 18/09/2025.
//

import Combine
import Navigation
import Settings
import Story
import Study
import Subscription
import Translation
import UserLimit
import Audio
import Loading

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
    public let loadingEnvironment: LoadingEnvironmentProtocol
    
    public init(
        settingsEnvironment: SettingsEnvironmentProtocol,
        storyEnvironment: StoryEnvironmentProtocol,
        studyEnvironment: StudyEnvironmentProtocol,
        subscriptionEnvironment: SubscriptionEnvironmentProtocol,
        translationEnvironment: TranslationEnvironmentProtocol,
        userLimitEnvironment: UserLimitEnvironmentProtocol,
        audioEnvironment: AudioEnvironmentProtocol,
        loadingEnvironment: LoadingEnvironmentProtocol
    ) {
        self.settingsEnvironment = settingsEnvironment
        self.storyEnvironment = storyEnvironment
        self.studyEnvironment = studyEnvironment
        self.subscriptionEnvironment = subscriptionEnvironment
        self.translationEnvironment = translationEnvironment
        self.userLimitEnvironment = userLimitEnvironment
        self.audioEnvironment = audioEnvironment
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
