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
    case updateAutoScrollEnabled(isEnabled: Bool)
    case updateSentenceIndex(Int)

    case createChapter(CreateChapterType)
    case failedToCreateChapter

    case showFreeLimitExplanationScreen(isShowing: Bool)
    case showDailyLimitExplanationScreen(isShowing: Bool)

    case translateStory(story: Story, storyString: String)
    case onTranslatedStory(story: Story)
    case failedToTranslateStory

    case didNotPassModeration
    case dismissFailedModerationAlert
    case showModerationDetails

    case updateIsShowingModerationDetails(isShowing: Bool)

    case failedToSaveStory

    case saveStoryAndSettings(Story)
    case onSavedStoryAndSettings
    case failedToSaveStoryAndSettings

    case deleteStory(Story)
    case onDeletedStory
    case failedToDeleteStory

    case deleteCustomPrompt(String)

    case selectChapter(Story, chapterIndex: Int)
    case onSelectedChapter

    case loadStories(isAppLaunch: Bool)
    case onLoadedStories([Story], isAppLaunch: Bool)
    case failedToLoadStories

    // 1) Request to load chapters for a specific story
    case loadChapters(Story, isAppLaunch: Bool)
    
    // 2) Called on success, includes the original Story + the loaded chapters
    case onLoadedChapters(Story, [Chapter], isAppLaunch: Bool)

    // 3) Called on failure
    case failedToLoadChapters

    case loadDefinitions
    case onLoadedDefinitions([Definition])
    case failedToLoadDefinitions

    case synthesizeAudio(Chapter,
                         story: Story,
                         voice: Voice,
                         isForced: Bool)
    case onSynthesizedAudio(ChapterAudio,
                            Story,
                            isForced: Bool)
    case playAudio(time: Double?)
    case pauseAudio
    case onPlayedAudio
    case failedToSynthesizeAudio
    case updatePlayTime

    case defineCharacter(WordTimeStampData, shouldForce: Bool)
    case playWord(WordTimeStampData, story: Story?)
    case prepareToPlayStudyWord(Definition)
    case failedToPrepareStudyWord
    case playStudyWord(Definition)
    case playStudySentence(startWord: WordTimeStampData, endWord: WordTimeStampData)
    case onDefinedCharacter(Definition)
    case onDefinedSentence([Definition], tappedDefinition: Definition)
    case failedToDefineCharacter
    case saveDefinitions
    case onSavedDefinitions
    case failedToSaveDefinitions

    case updateShowDefinition(Bool)
    case updateShowEnglish(Bool)
    case updateStudyChapter(Chapter?)

    case updateSpeechSpeed(SpeechSpeed)
    case updateDifficulty(Difficulty)
    case updateLanguage(Language)
    case selectWord(WordTimeStampData)

    case goToNextChapter
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

    case restoreSubscriptions
    case onRestoredSubscriptions
    case failedToRestoreSubscriptions

    case getCurrentEntitlements
    case updatePurchasedProducts([VerificationResult<Transaction>], isOnLaunch: Bool)

    case observeTransactionUpdates

    case setSubscriptionSheetShowing(Bool, SubscriptionSheetType)

    case showSnackBar(SnackBarType)
    case hideSnackbar

    case generateImage(passage: String, Story)
    case onGeneratedImage(Data, Story)
    case failedToGenerateImage
    case updateStudiedWord(Definition)

    case onDailyChapterLimitReached(nextAvailable: String)

    case playSound(AppSound)
    case playMusic(MusicType)
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

    case checkFreeTrialLimit
    case hasReachedFreeTrialLimit
    case hasReachedDailyLimit
}

enum SubscriptionSheetType {
    case manualOpen, freeLimitReached
}
