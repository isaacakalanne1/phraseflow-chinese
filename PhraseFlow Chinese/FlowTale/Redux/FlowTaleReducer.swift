//
//  FlowTaleReducer.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import SwiftUI
import ReduxKit
import AVKit
import StoreKit

let flowTaleReducer: Reducer<FlowTaleState, FlowTaleAction> = { state, action in
    var newState = state

    switch action {
    case .onLoadedAppSettings(let settings):
        newState.settingsState = settings
    case .onContinuedStory(let story):
        newState.storyState.currentStory = story
        newState.storyState.currentStory?.currentSentenceIndex = 0
        newState.audioState.audioPlayer = AVPlayer()
        newState.settingsState.language = story.language
    case .onLoadedStories(let stories):
        newState.storyState.savedStories = stories
        let currentStory = stories.first
        if newState.storyState.currentStory == nil,
           !stories.isEmpty {
            newState.storyState.currentStory = currentStory
            let data = newState.storyState.currentChapterAudioData
            let player = data?.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }
        newState.viewState.readerDisplayType = .normal
    case .playStudyWord(let definition):
        if let story = newState.storyState.savedStories.first(where: { def in
            def.id == definition.timestampData.storyId
        }),
           let chapter = story.chapters[safe: definition.timestampData.chapterIndex],
           let audioData = chapter.audioData,
           let player = audioData.createAVPlayer() {
            newState.studyState.audioPlayer = player
        }
    case .failedToLoadStories:
        newState.viewState.readerDisplayType = .normal
    case .updateSpeechSpeed(let speed):
        newState.settingsState.speechSpeed = speed
    case .defineCharacter(let wordTimeStampData, let shouldForce):
        newState.definitionState.tappedWord = wordTimeStampData
        newState.viewState.readerDisplayType = .defining
    case .onDefinedCharacter(let definition):
        newState.definitionState.currentDefinition = definition
        newState.definitionState.definitions.removeAll(where: {
            $0.timestampData == definition.timestampData && $0.sentence == definition.sentence
        })
        newState.definitionState.definitions.append(definition)
        newState.viewState.readerDisplayType = .normal
    case .synthesizeAudio:
        newState.viewState.playButtonDisplayType = .loading
    case .onSynthesizedAudio(var data):
        newState.storyState.currentStory?.currentPlaybackTime = 0
        newState.definitionState.currentDefinition = nil
        newState.viewState.playButtonDisplayType = .normal

        var newStory = newState.storyState.currentStory
        let chapterIndex = newStory?.currentChapterIndex ?? 0
        newStory?.chapters[chapterIndex].audioData = data.audioData
        newStory?.chapters[chapterIndex].audioSpeed = newState.settingsState.speechSpeed
        newStory?.chapters[chapterIndex].audioVoice = newState.settingsState.voice
        newStory?.chapters[chapterIndex].timestampData = data.wordTimestamps
        newState.storyState.currentStory = newStory

        let player = data.audioData.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        newState.viewState.readerDisplayType = .normal
    case .failedToSynthesizeAudio:
        newState.viewState.playButtonDisplayType = .normal
    case .updateShowDefinition(let isShowing):
        newState.settingsState.isShowingDefinition = isShowing
    case .updateShowEnglish(let isShowing):
        newState.settingsState.isShowingEnglish = isShowing
    case .updateShowingSettings(let isShowing):
        newState.viewState.isShowingSettingsScreen = isShowing
    case .updateShowingStoryListView(let isShowing):
        newState.viewState.isShowingStoryListView = isShowing
    case .updateShowingStudyView(let isShowing):
        newState.viewState.isShowingStudyView = isShowing
    case .updateShowingDefinitionsChartView(let isShowing):
        newState.viewState.isShowingDefinitionsChartView = isShowing
    case .updateAutoScrollEnabled(let isEnabled):
        newState.viewState.isAutoscrollEnabled = isEnabled
    case .selectChapter(var story, let chapterIndex):
        newState.viewState.isShowingStoryListView = false
        story.lastUpdated = .now
        if let chapter = story.chapters[safe: chapterIndex] {
            if let voice = chapter.audioVoice {
                newState.settingsState.voice = voice
            }
            if let speed = chapter.audioSpeed {
                newState.settingsState.speechSpeed = speed
            }

            story.currentChapterIndex = chapterIndex
        }
        newState.storyState.currentStory = story
        newState.settingsState.language = story.language


        let data = newState.storyState.currentChapterAudioData
        let player = data?.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
    case .onSelectedChapter:
        if let language = newState.storyState.currentStory?.language {
            newState.settingsState.language = language
        }
    case .continueStory:
        if let voice = newState.settingsState.language.voices.first {
            newState.settingsState.voice = voice
        }
        newState.viewState.readerDisplayType = .loading
        newState.viewState.isShowingStoryListView = false
    case .failedToContinueStory:
        newState.viewState.readerDisplayType = .failedToGenerateChapter
    case .updateSentenceIndex(let index):
        newState.storyState.currentStory?.currentSentenceIndex = index
    case .playAudio(let time):
        newState.currentTappedWord = nil
        newState.audioState.isPlayingAudio = true
        if let time {
            newState.storyState.currentStory?.currentPlaybackTime = time
            newState.storyState.currentStory?.currentPlaybackTime = time
        }
    case .pauseAudio:
        newState.audioState.isPlayingAudio = false
    case .updatePlayTime:
        newState.storyState.currentStory?.currentPlaybackTime = newState.audioState.audioPlayer.currentTime().seconds
        newState.storyState.currentStory?.currentPlaybackTime = newState.audioState.audioPlayer.currentTime().seconds
        if let index = newState.currentSpokenWord?.sentenceIndex {
            newState.storyState.currentStory?.currentSentenceIndex = index
        }
    case .selectWord(let word):
        newState.storyState.currentStory?.currentPlaybackTime = word.time
        newState.currentTappedWord = word
    case .goToNextChapter:
        var newStory = newState.storyState.currentStory
        newStory?.currentChapterIndex += 1
        newState.storyState.currentStory = newStory
        let data = newState.storyState.currentChapterAudioData
        let player = data?.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
    case .refreshChapterView:
        newState.viewState.chapterViewId = UUID()
    case .refreshDefinitionView:
        newState.viewState.definitionViewId = UUID()
    case .refreshTranslationView:
        newState.viewState.translationViewId = UUID()
    case .refreshStoryListView:
        newState.viewState.storyListViewId = UUID()
    case .selectVoice(let voice):
        newState.settingsState.voice = voice
    case .updateDifficulty(let difficulty):
        newState.settingsState.difficulty = difficulty
    case .updateLanguage(let language):
        newState.settingsState.language = language
    case .onLoadedDefinitions(let definitions):
        newState.definitionState.definitions = definitions
    case .onDeletedStory:
        newState.viewState.storyListViewId = UUID()
    case .onFetchedSubscriptions(let subscriptions):
        newState.subscriptionState.products = subscriptions
    case .updatePurchasedProducts(let entitlements):
        for result in entitlements {
            DispatchQueue.main.async {
                guard case .verified(let transaction) = result else {
                    return
                }

                if transaction.revocationDate == nil {
                    newState.subscriptionState.purchasedProductIDs.insert(transaction.productID)
                } else {
                    newState.subscriptionState.purchasedProductIDs.remove(transaction.productID)
                }
            }
        }
    case .setSubscriptionSheetShowing(let isShowing):
        newState.viewState.isShowingSubscriptionSheet = isShowing
    case .showSnackBar(let type):
        newState.snackBarState.type = type
        newState.snackBarState.isShowing = true
    case .hideSnackbar:
        newState.snackBarState.isShowing = false
    case .saveStoryAndSettings,
            .failedToSaveStory,
            .failedToDefineCharacter,
            .loadStories,
            .onPlayedAudio,
            .deleteStory,
            .failedToDeleteStory,
            .failedToSaveAppSettings,
            .failedToLoadAppSettings,
            .loadAppSettings,
            .saveAppSettings,
            .playWord,
            .loadDefinitions,
            .failedToLoadDefinitions,
            .saveDefinitions,
            .onSavedDefinitions,
            .failedToSaveDefinitions,
            .onSavedStoryAndSettings,
            .failedToSaveStoryAndSettings,
            .fetchSubscriptions,
            .failedToFetchSubscriptions,
            .purchaseSubscription,
            .onPurchasedSubscription,
            .failedToPurchaseSubscription,
            .getCurrentEntitlements,
            .restoreSubscriptions,
            .onRestoredSubscriptions,
            .failedToRestoreSubscriptions,
            .observeTransactionUpdates:
        break
    }

    return newState
}
