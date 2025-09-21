//
//  NavigationEnvironment.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Combine
import Foundation
import Story
import Audio
import Loading
import Study
import Settings
import Subscription
import Translation
import UserLimit

public struct NavigationEnvironment: NavigationEnvironmentProtocol {
    public let settingsEnvironment: SettingsEnvironmentProtocol
    public let storyEnvironment: StoryEnvironmentProtocol
    public let studyEnvironment: StudyEnvironmentProtocol
    public let subscriptionEnvironment: SubscriptionEnvironmentProtocol
    public let translationEnvironment: TranslationEnvironmentProtocol
    public let userLimitEnvironment: UserLimitEnvironmentProtocol
    public let audioEnvironment: AudioEnvironmentProtocol
    public let loadingEnvironment: LoadingEnvironmentProtocol

    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> {
        settingsEnvironment.settingsUpdatedSubject
    }
    
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
    }
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
}
