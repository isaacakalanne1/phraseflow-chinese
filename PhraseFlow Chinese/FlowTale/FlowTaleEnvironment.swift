//
//  FlowTaleEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import Foundation
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

protocol FlowTaleEnvironmentProtocol {
    var audioEnvironment: AudioEnvironmentProtocol { get }
    var storyEnvironment: StoryEnvironmentProtocol { get }
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var studyEnvironment: StudyEnvironmentProtocol { get }
    var translationEnvironment: TranslationEnvironmentProtocol { get }
    var subscriptionEnvironment: SubscriptionEnvironmentProtocol { get }
    var snackBarEnvironment: SnackBarEnvironmentProtocol { get }
    var userLimitEnvironment: UserLimitEnvironmentProtocol { get }
    var moderationEnvironment: ModerationEnvironmentProtocol { get }
    var navigationEnvironment: NavigationEnvironmentProtocol { get }
    var loadingEnvironment: LoadingEnvironmentProtocol { get }
}

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

struct MockFlowTaleEnvironment: FlowTaleEnvironmentProtocol {
    let audioEnvironment: AudioEnvironmentProtocol = MockAudioEnvironment()
    let storyEnvironment: StoryEnvironmentProtocol = MockStoryEnvironment()
    let settingsEnvironment: SettingsEnvironmentProtocol = MockSettingsEnvironment()
    let studyEnvironment: StudyEnvironmentProtocol = MockStudyEnvironment()
    let translationEnvironment: TranslationEnvironmentProtocol = MockTranslationEnvironment()
    let subscriptionEnvironment: SubscriptionEnvironmentProtocol = MockSubscriptionEnvironment()
    let snackBarEnvironment: SnackBarEnvironmentProtocol = MockSnackBarEnvironment()
    let userLimitEnvironment: UserLimitEnvironmentProtocol = MockUserLimitEnvironment()
    let moderationEnvironment: ModerationEnvironmentProtocol = MockModerationEnvironment()
    let navigationEnvironment: NavigationEnvironmentProtocol = MockNavigationEnvironment()
    let loadingEnvironment: LoadingEnvironmentProtocol = MockLoadingEnvironment()
}