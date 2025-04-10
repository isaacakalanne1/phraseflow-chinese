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
    case .studyAction(let studyAction):
        newState.studyState = studyReducer(state.studyState, studyAction)
        
    case .translationAction(let translationAction):
        newState.translationState = translationReducer(state.translationState, translationAction)
    case .updateCurrentSentence(let sentence):
        newState.storyState.currentSentence = sentence
    case .clearCurrentDefinition:
        newState.definitionState.currentDefinition = nil
    case .onLoadedAppSettings(let settings):
        newState.settingsState = settings
        newState.translationState.targetLanguage = settings.language
    case .onLoadedStories(let stories, let isAppLaunch):
        newState.storyState.savedStories = stories // TODO: Fix needing to tap definitions twice to get definition
        newState.viewState.isInitialisingApp = false
        newState.viewState.storyListViewId = UUID()
        if newState.storyState.currentStory == nil ||
           !stories.contains(where: { $0.id == newState.storyState.currentStory?.id }) {
            newState.storyState.currentStory = stories.first
            let data = newState.storyState.currentChapter?.audio.data
            let player = data?.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }
    case .onLoadedChapters(let story, let chapters, _):
        if let index = newState.storyState.savedStories.firstIndex(where: { $0.id == story.id }) {
            var updatedStory = newState.storyState.savedStories[index]
            updatedStory.chapters = chapters
            newState.storyState.savedStories[index] = updatedStory
        }
        if newState.storyState.currentStory?.id == story.id {
            newState.storyState.currentStory?.chapters = chapters
            let data = newState.storyState.currentChapter?.audio.data
            let player = data?.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }
        newState.storyState.currentSentence = newState.storyState.currentChapter?.sentences.last(where: { $0.timestamps.contains(where: { story.currentPlaybackTime >= $0.time }) })
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
//            player.rate = 10
//            player.enableRate = true
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
    case .failedToLoadStories:
        newState.viewState.isInitialisingApp = false
    case .updateSpeechSpeed(let speed):
        newState.settingsState.speechSpeed = speed
        if newState.audioState.audioPlayer.rate != 0 {
            newState.audioState.audioPlayer.rate = speed.playRate
        }
    case .defineSentence(let wordTimeStampData, let shouldForce):
        newState.viewState.isDefining = true
    case .onDefinedCharacter(var definition):
        definition.hasBeenSeen = true
        definition.creationDate = .now
        if definition.audioData == nil,
           let extractedAudio = AudioExtractor.shared.extractAudioSegment(
               from: state.audioState.audioPlayer,
               startTime: definition.timestampData.time,
               duration: definition.timestampData.duration
           ) {
            definition.audioData = extractedAudio
        }

        newState.definitionState.currentDefinition = definition
        newState.definitionState.definitions.removeAll(where: { $0.id == definition.id })
        newState.definitionState.definitions.append(definition)
        newState.viewState.isDefining = false
    case .onDefinedSentence(_, var definitions, var tappedDefinition):
        tappedDefinition.hasBeenSeen = true
        tappedDefinition.creationDate = .now
        
        newState.definitionState.currentDefinition = tappedDefinition
        newState.definitionState.definitions.append(contentsOf: definitions)
        newState.definitionState.definitions.removeAll(where: { $0.id == tappedDefinition.id })
        newState.definitionState.definitions.append(tappedDefinition)

        newState.viewState.isDefining = false
    case .updateShowDefinition(let isShowing):
        newState.settingsState.isShowingDefinition = isShowing
    case .updateShowEnglish(let isShowing):
        newState.settingsState.isShowingEnglish = isShowing
    case .updateAutoScrollEnabled(let isEnabled):
        newState.viewState.isAutoscrollEnabled = isEnabled
    case .selectChapter(var story, let chapterIndex):
        if let chapter = story.chapters[safe: chapterIndex] {
            newState.definitionState.currentDefinition = nil
            story.lastUpdated = .now
            newState.storyState.currentStory = story
            newState.settingsState.language = story.language

            if let voice = chapter.audioVoice {
                newState.settingsState.voice = voice
            }

            story.currentChapterIndex = chapterIndex
            let data = newState.storyState.currentChapter?.audio.data
            newState.audioState.audioPlayer = data?.createAVPlayer() ?? AVPlayer()
        }

    case .selectStoryFromSnackbar(var story):
        newState.definitionState.currentDefinition = nil
        story.lastUpdated = .now
        story.currentChapterIndex = story.chapters.count - 1
        
        if let chapter = story.chapters[safe: story.currentChapterIndex] {
            if let voice = chapter.audioVoice {
                newState.settingsState.voice = voice
            }
        }
        
        newState.storyState.currentStory = story
        newState.settingsState.language = story.language
        
        let data = newState.storyState.currentChapter?.audio.data
        let player = data?.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
    case .onSelectedChapter:
        if let language = newState.storyState.currentStory?.language {
            newState.settingsState.language = language
        }
    case .createChapter(let type):
        newState.viewState.isWritingChapter = true

        switch type {
        case .newStory:
            newState.viewState.shouldShowImageSpinner = true
        case .existingStory(let story):
            if let voice = story.chapters.last?.audioVoice {
                newState.settingsState.voice = voice
            }
            newState.viewState.shouldShowImageSpinner = story.imageData == nil
        }
        newState.viewState.loadingState = .writing
    case .failedToCreateChapter:
        newState.viewState.isWritingChapter = false
    case .playAudio(let time):
        newState.definitionState.currentDefinition = nil
        newState.audioState.isPlayingAudio = true
        if let wordTime = time {
            newState.storyState.currentStory?.currentPlaybackTime = wordTime
        }
    case .pauseAudio:
        newState.audioState.isPlayingAudio = false
    case .updatePlayTime:
        newState.storyState.currentStory?.currentPlaybackTime = newState.audioState.audioPlayer.currentTime().seconds
    case .playWord(let word, _):
        newState.storyState.currentStory?.currentPlaybackTime = word.time
    case .goToNextChapter:
        newState.viewState.chapterViewId = UUID()
        var newStory = newState.storyState.currentStory
        newStory?.currentChapterIndex += 1
        newState.storyState.currentStory = newStory
        let data = newState.storyState.currentChapter?.audio.data
        let player = data?.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        let sentence = newState.storyState.currentSentence
        newState.storyState.currentStory?.currentPlaybackTime = sentence?.timestamps.first?.time ?? 0.1
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
    case .onLoadedInitialDefinitions(let definitions):
        // Add the initial definitions to our state
        print("Loading \(definitions.count) initial definitions")
        newState.definitionState.definitions.addDefinitions(definitions)
        
        // Mark that the chapter is ready for viewing
        newState.viewState.loadingState = .complete

        newState.viewState.isWritingChapter = false

    case .loadRemainingDefinitions(_, _, _, let definitions):
        newState.definitionState.definitions.append(contentsOf: definitions)
        
    case .onLoadedDefinitions(let definitions):
        print("Loading \(definitions.count) definitions")
        print("Definitions with hasBeenSeen=true: \(definitions.filter { $0.hasBeenSeen }.count)")

        newState.definitionState.definitions.addDefinitions(definitions)
    case .deleteDefinition(let definition):
        newState.definitionState.definitions.removeAll(where: { $0.id == definition.id })
    case .onDeletedStory(let storyId):
        if newState.storyState.currentStory?.id == storyId {
            newState.storyState.currentStory = nil
            newState.viewState.contentTab = .storyList
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
        newState.viewState.isShowingSubscriptionSheet = isShowing
        if isShowing {
            newState.viewState.isWritingChapter = false
        }
    case .showSnackBar(let type),
          .showSnackBarThenSaveStory(let type, _):
        if let url = type.sound.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = 0.7
            newState.appAudioState.audioPlayer = player
        }
        newState.snackBarState.type = type
        newState.snackBarState.isShowing = true
    case .hideSnackbar:
        newState.snackBarState.isShowing = false
    case .failedToDefineSentence:
        newState.viewState.isDefining = false
    case .updateStudiedWord(var definition):
        // Add the current date to studied dates
        definition.studiedDates.append(.now)

        // Update the definition in the list
        if let index = newState.definitionState.definitions.firstIndex(where: { $0.timestampData == definition.timestampData }) {
            newState.definitionState.definitions.replaceSubrange(index...index, with: [definition])
        } else {
            newState.definitionState.definitions.append(definition)
        }
    case .updateCustomPrompt(let prompt):
        newState.settingsState.customPrompt = prompt
    case .passedModeration(let prompt):
        newState.settingsState.customPrompts.append(prompt)
        newState.settingsState.storySetting = .customPrompt(prompt)
    case .onCreatedChapter(var story):
        newState.definitionState.currentDefinition = nil
        newState.viewState.chapterViewId = UUID()

        story.currentPlaybackTime = 0
        story.currentChapterIndex = story.chapters.count - 1

        newState.storyState.currentStory = story
        newState.storyState.currentSentence = story.chapters.last?.sentences.first
        newState.viewState.contentTab = .reader

        let player = story.chapters.last?.audio.data.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()

        newState.snackBarState.type = .chapterReady
        newState.snackBarState.isShowing = true

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
    case .updateColorScheme(let colorScheme):
        newState.settingsState.appColorScheme = colorScheme
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
        newState.snackBarState.isShowing = false
    case .updateIsSubscriptionPurchaseLoading(let isLoading):
        newState.subscriptionState.isLoadingSubscriptionPurchase = isLoading
    case .purchaseSubscription:
        newState.subscriptionState.isLoadingSubscriptionPurchase = true
    case .onPurchasedSubscription,
            .failedToPurchaseSubscription:
        newState.subscriptionState.isLoadingSubscriptionPurchase = false
    case .updateLoadingState(let loadingState):
        newState.viewState.loadingState = loadingState
    case .saveStoryAndSettings,
            .failedToSaveStory,
            .loadStories,
            .onPlayedAudio,
            .deleteStory,
            .failedToDeleteStory,
            .failedToSaveAppSettings,
            .failedToLoadAppSettings,
            .loadAppSettings,
            .saveAppSettings,
            .loadDefinitions,
            .failedToLoadDefinitions,
            .loadInitialSentenceDefinitions,
            .saveDefinitions,
            .failedToSaveDefinitions,
            .failedToSaveStoryAndSettings,
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
            .loadChapters,
            .failedToLoadChapters,
            .checkFreeTrialLimit,
            .hasReachedDailyLimit,
            .onFinishedLoadedStories,
            .musicTrackFinished,
            .checkDeviceVolumeZero,
            .failedToDeleteDefinition:
        break
    }

    return newState
}
