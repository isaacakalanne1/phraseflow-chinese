//
//  NavigationEnvironmentProtocol.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Foundation
import Audio
import Settings
import Story
import Study
import Subscription
import Translation

public protocol NavigationEnvironmentProtocol {
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var storyEnvironment: StoryEnvironmentProtocol { get }
    var studyEnvironment: StudyEnvironmentProtocol { get }
    var subscriptionEnvironment: SubscriptionEnvironmentProtocol { get }
    var translationEnvironment: TranslationEnvironmentProtocol { get }
    var audioEnvironment: AudioEnvironmentProtocol { get }
    @MainActor func selectChapter(storyId: UUID)
    func playSound(_ sound: AppSound)
}
