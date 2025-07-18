//
//  FlowTaleAction.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Audio
import Story
import Settings
import Definition
import Study
import Translation
import Subscription
import SnackBar
import UserLimit
import Moderation
import Navigation

enum FlowTaleAction {
    case audioAction(AudioAction)
    case storyAction(StoryAction)
    case appSettingsAction(AppSettingsAction)
    case definitionAction(DefinitionAction)
    case studyAction(StudyAction)
    case translationAction(TranslationAction)
    case subscriptionAction(SubscriptionAction)
    case snackbarAction(SnackbarAction)
    case userLimitAction(UserLimitAction)
    case moderationAction(ModerationAction)
    case navigationAction(NavigationAction)
}