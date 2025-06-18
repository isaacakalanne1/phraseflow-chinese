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

    case deleteCustomPrompt(String)

    case selectChapter(Story, chapterIndex: Int)
    case selectStoryFromSnackbar(Story)
    case onSelectedChapter


    case updateShowDefinition(Bool)
    case updateShowEnglish(Bool)

    case updateSpeechSpeed(SpeechSpeed)
    case updateDifficulty(Difficulty)
    case updateLanguage(Language)

    case refreshChapterView
    case refreshTranslationView
    case refreshStoryListView

    case selectVoice(Voice)

    case loadAppSettings
    case onLoadedAppSettings(SettingsState)
    case failedToLoadAppSettings

    case saveAppSettings
    case failedToSaveAppSettings

    case fetchSubscriptions
    case onFetchedSubscriptions([Product])
    case failedToFetchSubscriptions

    case purchaseSubscription(Product)
    case onPurchasedSubscription
    case failedToPurchaseSubscription

    case updateIsSubscriptionPurchaseLoading(Bool)

    case restoreSubscriptions
    case onRestoredSubscriptions
    case failedToRestoreSubscriptions

    case getCurrentEntitlements
    case updatePurchasedProducts([VerificationResult<Transaction>], isOnLaunch: Bool)

    case observeTransactionUpdates
    case validateReceipt
    case onValidatedReceipt

    case setSubscriptionSheetShowing(Bool)

    case showSnackBar(SnackBarType)
    case hideSnackbar
    case checkDeviceVolumeZero


    case onDailyChapterLimitReached(nextAvailable: String)


    case updateCustomPrompt(String)
    case updateColorScheme(FlowTaleColorScheme)
    case updateShouldPlaySound(Bool)

    case moderateText(String)
    case onModeratedText(ModerationResponse, String)
    case failedToModerateText

    case passedModeration(String)

    case updateStorySetting(StorySetting)
    case updateIsShowingCustomPromptAlert(Bool)
    case selectTab(ContentTab, shouldPlaySound: Bool)


    case checkFreeTrialLimit
    case hasReachedFreeTrialLimit
    case hasReachedDailyLimit
}
