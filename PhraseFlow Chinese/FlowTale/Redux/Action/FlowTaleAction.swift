//
//  FlowTaleAction.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import AVKit
import Foundation
import StoreKit

enum FlowTaleAction {
    case studyAction(StudyAction)
    case translationAction(TranslationAction)
    case storyAction(StoryAction)
    case audioAction(AudioAction)
    case definitionAction(DefinitionAction)
    case subscriptionAction(SubscriptionAction)
    case appSettingsAction(AppSettingsAction)
    case moderationAction(ModerationAction)
    case userLimitAction(UserLimitAction)
    case navigationAction(NavigationAction)
    case snackbarAction(SnackbarAction)

    case updateCurrentSentence(Sentence)
    case updateAutoScrollEnabled(isEnabled: Bool)
    case updateLoadingState(LoadingState)
    case checkDeviceVolumeZero
}
