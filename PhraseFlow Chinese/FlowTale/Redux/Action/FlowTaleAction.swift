//
//  FlowTaleAction.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AVKit
import StoreKit

enum FlowTaleAction {
    case settingsAction(SettingsAction)
    case storyAction(StoryAction)
    case studyAction(StudyAction)
    case snackBarAction(SnackBarAction)

    case updateAutoScrollEnabled(isEnabled: Bool)
    case updateSentenceIndex(Int)

    case setMusicVolume(MusicVolume)

    case showFreeLimitExplanationScreen(isShowing: Bool)
    case showDailyLimitExplanationScreen(isShowing: Bool)

    case hideSnackbarThenSaveStoryAndSettings(Story)

    case didNotPassModeration
    case dismissFailedModerationAlert
    case showModerationDetails

    case updateIsShowingModerationDetails(isShowing: Bool)

    case loadThenShowReadySnackbar

    case deleteCustomPrompt(String)



    case loadDefinitions(Language)
    case onLoadedDefinitions([Sentence])
    case failedToLoadDefinitions

    case playAudio(time: Double?)
    case pauseAudio
    case onPlayedAudio
    case updatePlayTime

    case defineCharacter(WordTimeStampData, shouldForce: Bool)
    case playWord(WordTimeStampData, story: Story?)
    case onDefinedCharacter(WordTimeStampData)
    case onDefinedSentence([Definition], tappedWord: WordTimeStampData)
    case failedToDefineCharacter

    case updateShowDefinition(Bool)
    case updateShowEnglish(Bool)

    case updateSpeechSpeed(SpeechSpeed)
    case updateDifficulty(Difficulty)
    case updateLanguage(Language)
    case selectWord(WordTimeStampData)

    case refreshChapterView
    case refreshDefinitionView
    case refreshTranslationView
    case refreshStoryListView
    
    case selectVoice(Voice)

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

    case checkDeviceVolumeZero

    case updateStudiedWord(WordTimeStampData, Sentence)

    case onDailyChapterLimitReached(nextAvailable: String)

    case playSound(AppSound)
    case playMusic(MusicType)
    case musicTrackFinished(MusicType)
    case stopMusic
    
    case updateCustomPrompt(String)
    case updateShouldPlaySound(Bool)
    case deleteDefinition(WordTimeStampData, Sentence)

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
