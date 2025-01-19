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
    case .translateStory:
        newState.viewState.loadingState = .translating
    case .generateImage:
        newState.viewState.loadingState = .generatingImage
    case .onLoadedStories(let stories, _):
        newState.storyState.savedStories = stories
        newState.viewState.readerDisplayType = .normal
        
        if newState.storyState.currentStory == nil,
           let currentStory = stories.first {
            newState.storyState.currentStory = currentStory
            let data = newState.storyState.currentChapterAudioData
            let player = data?.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }
    case .onLoadedChapters(let story, let chapters):
        // 1) Find this story in savedStories (or currentStory)
        //    We’ll do both, depending on how your app organizes it.

        // Example: update in savedStories
        if let index = newState.storyState.savedStories.firstIndex(where: { $0.id == story.id }) {
            var updatedStory = newState.storyState.savedStories[index]
            // 2) Merge the newly loaded chapters into the story object
            updatedStory.chapters = chapters
            // 3) Update the array
            newState.storyState.savedStories[index] = updatedStory
        }

        // If you also keep a `currentStory`, and it's the same story, update that too:
        if newState.storyState.currentStory?.id == story.id {
            newState.storyState.currentStory?.chapters = chapters
        }

        return newState
    case .playStudyWord(let definition):
        if let story = newState.storyState.savedStories.first(where: { def in
            def.id == definition.timestampData.storyId
        }),
           let chapter = story.chapters[safe: definition.timestampData.chapterIndex],
           let player = chapter.audio.data.createAVPlayer() {
            newState.studyState.audioPlayer = player
        }
    case .playSound(let sound):
        if let url = sound.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = 0.7
            newState.appAudioState.audioPlayer = player
        }
    case .playMusic(let music):
        if let url = music.fileURL,
        let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = -1
            player.volume = 0.3
            newState.musicAudioState.audioPlayer = player
            newState.settingsState.isPlayingMusic = true
        }
    case .stopMusic:
        newState.settingsState.isPlayingMusic = false
    case .failedToLoadStories:
        newState.viewState.readerDisplayType = .normal
    case .updateSpeechSpeed(let speed):
        newState.settingsState.speechSpeed = speed
    case .defineCharacter(let wordTimeStampData, let shouldForce):
        newState.definitionState.tappedWord = wordTimeStampData
        newState.viewState.isDefining = true
    case .onDefinedCharacter(let definition):
        newState.definitionState.currentDefinition = definition
        newState.definitionState.definitions.removeAll(where: {
            $0.timestampData == definition.timestampData && $0.sentence == definition.sentence
        })
        newState.definitionState.definitions.append(definition)
        newState.viewState.isDefining = false
    case .synthesizeAudio:
        newState.viewState.playButtonDisplayType = .loading
        newState.viewState.loadingState = .generatingSpeech
    case .onSynthesizedAudio(var data, var newStory, let isForced):
        if !isForced {
            newState.viewState.contentTab = .reader
        }
        newState.definitionState.currentDefinition = nil
        newState.viewState.chapterViewId = UUID()
        newState.viewState.playButtonDisplayType = .normal
        newState.viewState.loadingState = .complete
        newState.viewState.contentTab = .reader

        newStory.currentPlaybackTime = 0
        newStory.currentSentenceIndex = 0
        newStory.currentChapterIndex = newStory.chapters.count - 1
        newStory.chapters[newStory.currentChapterIndex].audio = data
        newStory.chapters[newStory.currentChapterIndex].audioSpeed = newState.settingsState.speechSpeed
        newStory.chapters[newStory.currentChapterIndex].audioVoice = newState.settingsState.voice
        newState.storyState.currentStory = newStory

        let player = data.data.createAVPlayer()
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
        newState.definitionState.currentDefinition = nil
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
        newState.viewState.loadingState = .writing
        newState.viewState.isShowingStoryListView = false
    case .failedToContinueStory,
            .failedToTranslateStory,
            .failedToGenerateImage:
        newState.viewState.readerDisplayType = .normal
    case .updateSentenceIndex(let index):
        newState.storyState.currentStory?.currentSentenceIndex = index
    case .playAudio(let time):
        newState.currentTappedWord = nil
        newState.definitionState.currentDefinition = nil
        newState.audioState.isPlayingAudio = true
        if let wordTime = time {
            newState.storyState.currentStory?.currentPlaybackTime = wordTime
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
    case .showSnackBar(let type):
        if let url = type.sound.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = 0.7
            newState.appAudioState.audioPlayer = player
        }
        newState.snackBarState.type = type
        newState.snackBarState.isShowing = true
    case .hideSnackbar:
        newState.snackBarState.isShowing = false
    case .failedToDefineCharacter:
        newState.viewState.isDefining = false
    case .onTranslatedStory(let story):
        newState.audioState.audioPlayer = AVPlayer()
        newState.settingsState.language = story.language
    case .updateStudiedWord(var definition):
        definition.studiedDates.append(.now)
        var allDefinitions = newState.definitionState.definitions
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
    case .onModeratedText(let response, _):
        newState.moderationResponse = response
    case .didNotPassModeration:
        newState.viewState.isShowingModerationFailedAlert = true
    case .dismissFailedModerationAlert:
        newState.viewState.isShowingModerationFailedAlert = false
    case .showModerationDetails:
        // We'll dismiss the alert (if it's open) and show the details screen.
        newState.viewState.isShowingModerationFailedAlert = false
        newState.viewState.isShowingModerationDetails = true
    case .updateIsShowingModerationDetails(let isShowing):
        newState.viewState.isShowingModerationDetails = isShowing
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
            .observeTransactionUpdates,
            .onGeneratedImage,
            .moderateText,
            .failedToModerateText,
            .didNotPassModeration,
            .loadChapters,
            .failedToLoadChapters:
        break
    }

    return newState
}
