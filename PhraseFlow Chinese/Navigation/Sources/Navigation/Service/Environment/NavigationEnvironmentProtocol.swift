//
//  NavigationEnvironmentProtocol.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Combine
import Foundation
import Audio
import Loading
import Settings
import Story
import Study
import Subscription
import Translation
import UserLimit

public protocol NavigationEnvironmentProtocol {
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var storyEnvironment: StoryEnvironmentProtocol { get }
    var studyEnvironment: StudyEnvironmentProtocol { get }
    var subscriptionEnvironment: SubscriptionEnvironmentProtocol { get }
    var translationEnvironment: TranslationEnvironmentProtocol { get }
    var userLimitEnvironment: UserLimitEnvironmentProtocol { get }
    var audioEnvironment: AudioEnvironmentProtocol { get }
    var loadingEnvironment: LoadingEnvironmentProtocol { get }
    
    var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> { get }
    
    func playSound(_ sound: AppSound)
}
