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
    case updateCurrentSentence(Sentence)
    case updateAutoScrollEnabled(isEnabled: Bool)
    case clearCurrentDefinition

    case updateLoadingState(LoadingState)




    case failedToSaveStory

    case hideSnackbarThenSaveStoryAndSettings(Story)
    case failedToSaveStoryAndSettings
    case showSnackBarThenSaveStory(SnackBarType, Story)

    case selectChapter(Story, chapterIndex: Int)
    case onSelectedChapter

    case showSnackBar(SnackBarType)
    case hideSnackbar
    case checkDeviceVolumeZero
    case selectTab(ContentTab, shouldPlaySound: Bool)


}
