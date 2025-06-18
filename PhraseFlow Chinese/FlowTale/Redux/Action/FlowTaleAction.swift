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
    case updateCurrentSentence(Sentence)
    case updateAutoScrollEnabled(isEnabled: Bool)
    case clearCurrentDefinition

    case updateLoadingState(LoadingState)


    case showFreeLimitExplanationScreen(isShowing: Bool)
    case showDailyLimitExplanationScreen(isShowing: Bool)

    case didNotPassModeration
    case dismissFailedModerationAlert
    case showModerationDetails

    case updateIsShowingModerationDetails(isShowing: Bool)

    case failedToSaveStory

    case hideSnackbarThenSaveStoryAndSettings(Story)
    case failedToSaveStoryAndSettings
    case showSnackBarThenSaveStory(SnackBarType, Story)


    case selectChapter(Story, chapterIndex: Int)
    case selectStoryFromSnackbar(Story)
    case onSelectedChapter


    case refreshChapterView
    case refreshTranslationView
    case refreshStoryListView


    case showSnackBar(SnackBarType)
    case hideSnackbar
    case checkDeviceVolumeZero


    case onDailyChapterLimitReached(nextAvailable: String)



    case moderateText(String)
    case onModeratedText(ModerationResponse, String)
    case failedToModerateText

    case passedModeration(String)

    case selectTab(ContentTab, shouldPlaySound: Bool)


    case checkFreeTrialLimit
    case hasReachedFreeTrialLimit
    case hasReachedDailyLimit
}
