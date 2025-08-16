//
//  NavigationEnvironment.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Foundation
import Story
import Audio
import Study
import Settings
import Subscription
import Translation
import DataStorage

public struct NavigationEnvironment: NavigationEnvironmentProtocol {
    public let settingsEnvironment: SettingsEnvironmentProtocol
    public let storyEnvironment: StoryEnvironmentProtocol
    public let studyEnvironment: StudyEnvironmentProtocol
    public let subscriptionEnvironment: SubscriptionEnvironmentProtocol
    public let translationEnvironment: TranslationEnvironmentProtocol
    public let audioEnvironment: AudioEnvironmentProtocol
    
    public init(
        settingsEnvironment: SettingsEnvironmentProtocol,
        storyEnvironment: StoryEnvironmentProtocol,
        studyEnvironment: StudyEnvironmentProtocol,
        subscriptionEnvironment: SubscriptionEnvironmentProtocol,
        translationEnvironment: TranslationEnvironmentProtocol,
        audioEnvironment: AudioEnvironmentProtocol
    ) {
        self.settingsEnvironment = settingsEnvironment
        self.storyEnvironment = storyEnvironment
        self.studyEnvironment = studyEnvironment
        self.subscriptionEnvironment = subscriptionEnvironment
        self.translationEnvironment = translationEnvironment
        self.audioEnvironment = audioEnvironment
    }
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
}
