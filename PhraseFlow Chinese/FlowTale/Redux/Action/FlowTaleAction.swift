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
    case updateCurrentSentence(Sentence)
    case updateAutoScrollEnabled(isEnabled: Bool)
    case clearCurrentDefinition

    case updateLoadingState(LoadingState)

    case failedToCreateChapter

    case setMusicVolume(MusicVolume)

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

    case loadDefinitions
    case loadInitialSentenceDefinitions(Chapter, Story, Int)
    case onLoadedInitialDefinitions([Definition])
    case loadRemainingDefinitions(Chapter, Story, sentenceIndex: Int, previousDefinitions: [Definition])
    case onLoadedDefinitions([Definition])
    case failedToLoadDefinitions

    case playAudio(time: Double?)
    case pauseAudio
    case onPlayedAudio
    case updatePlayTime

    case defineSentence(WordTimeStampData, shouldForce: Bool)
    case playWord(WordTimeStampData, story: Story?)
    case onDefinedCharacter(Definition)
    case onDefinedSentence(Sentence, [Definition], Definition)
    case failedToDefineSentence
    case saveDefinitions
    case failedToSaveDefinitions

    case updateShowDefinition(Bool)
    case updateShowEnglish(Bool)

    case updateSpeechSpeed(SpeechSpeed)
    case updateDifficulty(Difficulty)
    case updateLanguage(Language)

    case refreshChapterView
    case refreshDefinitionView
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

    case updateStudiedWord(Definition)

    case onDailyChapterLimitReached(nextAvailable: String)

    case playSound(AppSound)
    case playMusic(MusicType)
    case musicTrackFinished(MusicType)
    case stopMusic

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

    case deleteDefinition(Definition)
    case failedToDeleteDefinition

    case checkFreeTrialLimit
    case hasReachedFreeTrialLimit
    case hasReachedDailyLimit
}
