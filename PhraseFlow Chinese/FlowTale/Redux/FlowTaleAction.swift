//
//  FlowTaleAction.swift
//  FlowTale
//
//  Created by Claude on 26/07/2025.
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

enum FlowTaleAction {
    case audioAction(AudioAction)
    case storyAction(StoryAction)
    case settingsAction(SettingsAction)
    case studyAction(StudyAction)
    case translationAction(TranslationAction)
    case subscriptionAction(SubscriptionAction)
    case snackBarAction(SnackbarAction)
    case userLimitAction(UserLimitAction)
    case moderationAction(ModerationAction)
    case navigationAction(NavigationAction)
    case loadingAction(LoadingAction)
    case viewAction(ViewAction)
    case loadAppSettings
    case playSound(SoundEffect)
}

enum ViewAction {
    case setInitializingApp(Bool)
    case setContentTab(ContentTab)
    case setSubscriptionSheetShowing(Bool)
    case setDailyLimitExplanationShowing(Bool)
    case setFreeLimitExplanationShowing(Bool)
    case setDefining(Bool)
    case setWritingChapter(Bool)
    case setDefinitionViewId(UUID)
    case setShowingCustomPromptAlert(Bool)
}

enum SoundEffect {
    case progressUpdate
}