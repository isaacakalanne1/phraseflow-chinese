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
    case .settingsAction(let settingsAction):
        newState.settingsState = settingsReducer(state.settingsState, settingsAction)
    case .storyAction(let storyAction):
        newState.storyState = storyReducer(state.storyState, storyAction)
    case .studyAction(let studyAction):
        newState.studyState = studyReducer(state.studyState, studyAction)
    case .snackBarAction(let snackBarAction):
        newState.snackBarState = snackBarReducer(state.snackBarState, snackBarAction)
    case .onLoadedDefinitions(let sentences):
        newState.definitionState.studySentences = sentences
    case .playSound(let sound):
        if let url = sound.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = 0.7
            newState.appAudioState.audioPlayer = player
        }
    case .playMusic(let music):
        if let url = music.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = 0
            player.volume = MusicVolume.normal.float
            newState.musicAudioState.currentMusicType = music
            newState.musicAudioState.audioPlayer = player
            newState.settingsState.isPlayingMusic = true
        }
    case .setMusicVolume(let volume):
        newState.musicAudioState.volume = volume
    case .stopMusic:
        newState.settingsState.isPlayingMusic = false
        newState.musicAudioState.audioPlayer.stop()
        newState.musicAudioState.currentMusicType = .whispersOfTheForest
    case .updateSpeechSpeed(let speed):
        newState.settingsState.speechSpeed = speed
        if newState.storyState.audioPlayer.rate != 0 {
            newState.storyState.audioPlayer.rate = speed.playRate
        }
    case .defineCharacter(let wordTimeStampData, let shouldForce):
        newState.viewState.isDefining = true
    case .onDefinedCharacter(var word):
        word.definition?.creationDate = .now
        word.hasBeenSeen = true
        if let wordIndex = newState.storyState.currentSentence?.wordTimestamps.firstIndex(where: { $0.id == word.id }) {
            newState.storyState.currentSentence?.wordTimestamps[wordIndex] = word
        }
        newState.definitionState.currentWord = word
        newState.viewState.isDefining = false
    case .onDefinedSentence(var definitions, var tappedWord):
        if let timestamps = newState.storyState.currentSentence?.wordTimestamps {

            let minCount = min(timestamps.count, definitions.count)

            newState.storyState.currentSentence?
                .wordTimestamps = zip(
                    timestamps.prefix(minCount),
                    definitions.prefix(minCount)
                )
                .map { (timestamp, definition) -> WordTimeStampData in
                    var newTimestamp = timestamp
                    if newTimestamp == tappedWord {
                        tappedWord.definition = definition
                        newTimestamp.hasBeenSeen = true
                    }
                    newTimestamp.definition = definition
                    return newTimestamp
                }
        }
        newState.definitionState.currentWord = tappedWord
        newState.viewState.isDefining = false
    case .updateShowDefinition(let isShowing):
        newState.settingsState.isShowingDefinition = isShowing
    case .updateShowEnglish(let isShowing):
        newState.settingsState.isShowingEnglish = isShowing
    case .updateAutoScrollEnabled(let isEnabled):
        newState.viewState.isAutoscrollEnabled = isEnabled
    case .updateSentenceIndex(let index):
        newState.storyState.currentStory?.currentSentenceIndex = index
    case .playAudio(let time):
        newState.definitionState.currentWord = nil
        newState.storyState.isPlayingAudio = true
        if let wordTime = time {
            newState.storyState.currentStory?.currentPlaybackTime = wordTime
        }
    case .pauseAudio:
        newState.storyState.isPlayingAudio = false
    case .updatePlayTime:
        newState.storyState.currentStory?.currentPlaybackTime = newState.storyState.audioPlayer.currentTime().seconds

        // Determine which sentence is currently being spoken by finding the sentence containing the current spoken word
        if let currentWord = newState.storyState.currentSpokenWord,
           let chapter = newState.storyState.currentChapter {
            
            // Find which sentence contains this word
            for (sentenceIndex, sentence) in chapter.sentences.enumerated() {
                if sentence.wordTimestamps.contains(where: { $0.id == currentWord.id }) {
                    newState.storyState.currentStory?.currentSentenceIndex = sentenceIndex
                    break
                }
            }
        }
    case .selectWord(let word):
        newState.storyState.currentStory?.currentPlaybackTime = word.time
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
        if language != newState.settingsState.language {
            newState.settingsState.language = language
            
            if let voice = language.voices.first {
                newState.settingsState.voice = voice
            }
        }
    case .onFetchedSubscriptions(let subscriptions):
        newState.subscriptionState.products = subscriptions
    case .updatePurchasedProducts(let entitlements, _):
        for result in entitlements {
            switch result {
            case .unverified(let transaction, _),
                    .verified(let transaction):
                if transaction.revocationDate == nil {
                    newState.subscriptionState.purchasedProductIDs.insert(transaction.productID)
                } else {
                    newState.subscriptionState.purchasedProductIDs.remove(transaction.productID)
                }
            }
        }
    case .setSubscriptionSheetShowing(let isShowing):
        newState.storyState.readerDisplayType = .normal
        newState.viewState.isShowingSubscriptionSheet = isShowing
    case .failedToDefineCharacter:
        newState.viewState.isDefining = false
    case .updateCustomPrompt(let prompt):
        newState.settingsState.customPrompt = prompt
    case .passedModeration(let prompt):
        newState.settingsState.customPrompts.append(prompt)
        newState.settingsState.storySetting = .customPrompt(prompt)
    case .updateStorySetting(let setting):
        switch setting {
        case .random:
            newState.settingsState.storySetting = setting
        case .customPrompt(let prompt):
            let isExistingPrompt = state.settingsState.customPrompts.contains(prompt)
            if isExistingPrompt {
                newState.settingsState.storySetting = setting
            }
        }
        newState.settingsState.storySetting = setting
    case .updateIsShowingCustomPromptAlert(let isShowing):
        newState.viewState.isShowingCustomPromptAlert = isShowing
    case .selectTab(let tab, _):
        newState.viewState.contentTab = tab
        newState.definitionState.currentWord = nil
    case .deleteCustomPrompt(let prompt):
        newState.settingsState.customPrompts.removeAll(where: { $0 == prompt })
        if newState.settingsState.storySetting == .customPrompt(prompt) {
            newState.settingsState.storySetting = .random
        }
    case .onModeratedText(let response, _):
        newState.moderationResponse = response
    case .didNotPassModeration:
        newState.viewState.isShowingModerationFailedAlert = true
    case .dismissFailedModerationAlert:
        newState.viewState.isShowingModerationFailedAlert = false
    case .showModerationDetails:
        newState.viewState.isShowingModerationFailedAlert = false
        newState.viewState.isShowingModerationDetails = true
    case .updateIsShowingModerationDetails(let isShowing):
        newState.viewState.isShowingModerationDetails = isShowing
    case .updateShouldPlaySound(let shouldPlaySound):
        newState.settingsState.shouldPlaySound = shouldPlaySound
    case .showDailyLimitExplanationScreen(let isShowing):
        newState.viewState.isShowingDailyLimitExplanation = isShowing
    case .showFreeLimitExplanationScreen(let isShowing):
        newState.viewState.isShowingFreeLimitExplanation = isShowing
    case .hasReachedFreeTrialLimit:
        newState.subscriptionState.hasReachedFreeTrialLimit = true
    case .onDailyChapterLimitReached(let nextAvailable):
        newState.subscriptionState.nextAvailableDescription = nextAvailable
    case .hideSnackbarThenSaveStoryAndSettings:
        newState.snackBarState.type = nil
    case .updateIsSubscriptionPurchaseLoading(let isLoading):
        newState.subscriptionState.isLoadingSubscriptionPurchase = isLoading
    case .purchaseSubscription:
        newState.subscriptionState.isLoadingSubscriptionPurchase = true
    case .onPurchasedSubscription,
            .failedToPurchaseSubscription:
        newState.subscriptionState.isLoadingSubscriptionPurchase = false
    case .onPlayedAudio,
            .playWord,
            .fetchSubscriptions,
            .failedToFetchSubscriptions,
            .getCurrentEntitlements,
            .restoreSubscriptions,
            .onRestoredSubscriptions,
            .failedToRestoreSubscriptions,
            .observeTransactionUpdates,
            .validateReceipt,
            .onValidatedReceipt,
            .moderateText,
            .failedToModerateText,
            .checkFreeTrialLimit,
            .hasReachedDailyLimit,
            .loadThenShowReadySnackbar,
            .musicTrackFinished,
            .checkDeviceVolumeZero,
            .loadDefinitions,
            .updateStudiedWord,
            .failedToLoadDefinitions,
            .deleteDefinition:
        break
    }

    return newState
}
