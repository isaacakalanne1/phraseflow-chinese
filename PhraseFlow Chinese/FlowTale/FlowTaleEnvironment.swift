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

// TODO: Implement proper mock environment according to refactoring guide
// For now, this is a placeholder to get the project compiling
extension FlowTaleEnvironment {
    static var mock: FlowTaleEnvironment {
        fatalError("Mock FlowTaleEnvironment not implemented - refactoring needed")
    }
}