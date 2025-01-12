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
    case updateShowingSettings(isShowing: Bool)
    case updateShowingStoryListView(isShowing: Bool)
    case updateShowingStudyView(isShowing: Bool)
    case updateShowingDefinitionsChartView(isShowing: Bool)
    case updateAutoScrollEnabled(isEnabled: Bool)
    case updateSentenceIndex(Int)

    case continueStory(story: Story)
    case failedToContinueStory(story: Story)

    case translateStory(story: Story, storyString: String)
    case onTranslatedStory(story: Story)
    case failedToTranslateStory(story: Story, storyString: String)

    case failedToSaveStory

    case saveStoryAndSettings(Story)
    case onSavedStoryAndSettings
    case failedToSaveStoryAndSettings

    case deleteStory(Story)
    case onDeletedStory
    case failedToDeleteStory

    case selectChapter(Story, chapterIndex: Int)
    case onSelectedChapter

    case loadStories
    case onLoadedStories([Story])
    case failedToLoadStories

    case loadDefinitions
    case onLoadedDefinitions([Definition])
    case failedToLoadDefinitions

    case synthesizeAudio(Chapter,
                         story: Story,
                         voice: Voice,
                         isForced: Bool)
    case onSynthesizedAudio((wordTimestamps: [WordTimeStampData],
                             audioData: Data),
                            Story)
    case playAudio(time: Double?)
    case pauseAudio
    case onPlayedAudio
    case failedToSynthesizeAudio
    case updatePlayTime

    case defineCharacter(WordTimeStampData, shouldForce: Bool)
    case playWord(WordTimeStampData, story: Story?)
    case playStudyWord(Definition)
    case onDefinedCharacter(Definition)
    case failedToDefineCharacter
    case saveDefinitions
    case onSavedDefinitions
    case failedToSaveDefinitions

    case updateShowDefinition(Bool)
    case updateShowEnglish(Bool)

    case updateSpeechSpeed(SpeechSpeed)
    case updateDifficulty(Difficulty)
    case updateLanguage(Language)
    case updateStoryPrompt(String)
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

    case setSubscriptionSheetShowing(Bool)

    case showSnackBar(SnackBarType)
    case hideSnackbar

    case generateImage(passage: String, Story)
    case onGeneratedImage(Data, Story)
    case failedToGenerateImage(Story)
    case updateStudiedWord(Definition)

    case playSound(AppSound)
    case playMusic(MusicType)
    case stopMusic

    case updateCustomPrompt(String)

    case moderateText(String)
    case onModeratedText(ModerationResponse, String)
    case failedToModerateText

    case passedModeration(String)
    case didNotPassModeration

    case updateStorySetting(StorySetting)
    case updateIsShowingCustomPromptAlert(Bool)
}
