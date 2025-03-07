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
    case .onLoadedStories(let stories, let isAppLaunch):
        newState.storyState.savedStories = stories
        if isAppLaunch {
            newState.viewState.readerDisplayType = .normal
        }

        // Setup the current story in these cases:
        // 1. If there is no current story (nil)
        // 2. If the current story no longer exists in the saved stories (i.e. was deleted)
        if newState.storyState.currentStory == nil || 
           !stories.contains(where: { $0.id == newState.storyState.currentStory?.id }) {
            if let firstStory = stories.first {
                // Make the first story the current one
                newState.storyState.currentStory = firstStory
                let data = newState.storyState.currentChapterAudioData
                let player = data?.createAVPlayer()
                newState.audioState.audioPlayer = player ?? AVPlayer()
            } else {
                // No stories left
                newState.storyState.currentStory = nil
                newState.viewState.contentTab = .reader
                newState.audioState.audioPlayer = AVPlayer()
            }
        }
    case .onLoadedChapters(let story, let chapters, _):
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
            let data = newState.storyState.currentChapterAudioData
            let player = data?.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }

        return newState
    case .updateStudyChapter(let chapter):
        newState.studyState.currentChapter = chapter
    case .playStudyWord:
        newState.studyState.audioPlayer = newState.studyState.currentChapter?.audio.data.createAVPlayer() ?? AVPlayer()
    case .playStudySentence:
        newState.studyState.audioPlayer = newState.studyState.currentChapter?.audio.data.createAVPlayer() ?? AVPlayer()
        newState.studyState.isAudioPlaying = true
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
        newState.viewState.readerDisplayType = .normal
    case .updateSpeechSpeed(let speed):
        newState.settingsState.speechSpeed = speed
        if newState.audioState.audioPlayer.rate != 0 {
            newState.audioState.audioPlayer.rate = speed.playRate
        }
    case .defineCharacter(let wordTimeStampData, let shouldForce):
        newState.viewState.isDefining = true
    case .onDefinedCharacter(var definition):
        // Mark the definition as seen
        definition.hasBeenSeen = true
        definition.creationDate = .now

        newState.definitionState.currentDefinition = definition
        newState.definitionState.definitions.removeAll(where: {
            $0.timestampData == definition.timestampData && $0.sentence == definition.sentence
        })
        newState.definitionState.definitions.append(definition)
        newState.viewState.isDefining = false
    case .onDefinedSentence(var definitions, var tappedDefinition):
        tappedDefinition.hasBeenSeen = true
        tappedDefinition.creationDate = .now
        definitions.removeAll(where: {
            $0.timestampData == tappedDefinition.timestampData
        })
        definitions.append(tappedDefinition)
        newState.definitionState.currentDefinition = tappedDefinition
        for definition in definitions {
            newState.definitionState.definitions.removeAll(where: {
                $0 == definition
            })
            newState.definitionState.definitions.append(definition)
        }
        newState.viewState.isDefining = false
    case .synthesizeAudio:
        newState.viewState.loadingState = .generatingSpeech
    case .onSynthesizedAudio(var data, var newStory, let isForced):
        newState.definitionState.currentDefinition = nil
        newState.viewState.chapterViewId = UUID()
        newState.viewState.loadingState = .complete
        
        // Reset the writing chapter flag
        newState.viewState.isWritingChapter = false
        
        // For existing users, we don't set the current story
        // They'll need to tap the snackbar to load it
        let hasExistingStories = newState.storyState.savedStories.count > 1
        let isNewStoryCreation = newStory.chapters.count == 1
        
        newStory.currentPlaybackTime = 0
        newStory.currentSentenceIndex = 0
        newStory.currentChapterIndex = newStory.chapters.count - 1
        newStory.chapters[newStory.currentChapterIndex].audio = data
        newStory.chapters[newStory.currentChapterIndex].audioSpeed = newState.settingsState.speechSpeed
        newStory.chapters[newStory.currentChapterIndex].audioVoice = newState.settingsState.voice
        
        // Only set current story for new users (first story) or forced updates
        if (isNewStoryCreation && !hasExistingStories) || isForced {
            newState.storyState.currentStory = newStory
            newState.viewState.contentTab = .reader
            
            // Set up audio player for immediate use
            let player = data.data.createAVPlayer()
            newState.audioState.audioPlayer = player ?? AVPlayer()
        }
        
        // Show the appropriate snackbar immediately based on the type of story being created
        if !isNewStoryCreation {
            // For new chapters in existing stories, show the "Chapter ready" snackbar
            newState.snackBarState.type = .chapterReady
            newState.snackBarState.isShowing = true
        } else if hasExistingStories {
            // For new stories when user has other stories, show the "Story ready" snackbar
            newState.snackBarState.type = .storyReadyTapToRead
            newState.snackBarState.isShowing = true
        }
        
        newState.viewState.readerDisplayType = .normal
    case .updateShowDefinition(let isShowing):
        newState.settingsState.isShowingDefinition = isShowing
    case .updateShowEnglish(let isShowing):
        newState.settingsState.isShowingEnglish = isShowing
    case .updateAutoScrollEnabled(let isEnabled):
        newState.viewState.isAutoscrollEnabled = isEnabled
    case .selectChapter(var story, let chapterIndex):
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
        
    case .selectStoryFromSnackbar(var story):
        // Similar to selectChapter but sets index to the latest chapter
        newState.definitionState.currentDefinition = nil
        story.lastUpdated = .now
        story.currentChapterIndex = story.chapters.count - 1
        
        if let chapter = story.chapters[safe: story.currentChapterIndex] {
            if let voice = chapter.audioVoice {
                newState.settingsState.voice = voice
            }
            if let speed = chapter.audioSpeed {
                newState.settingsState.speechSpeed = speed
            }
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
    case .createChapter(let type):
        // Set flag to indicate a chapter is being written
        newState.viewState.isWritingChapter = true
        
        switch type {
        case .newStory:
            // For new stories, we've already handled this in the view with the hasExistingStories check
            let hasExistingStories = !newState.storyState.savedStories.isEmpty
            if !hasExistingStories {
                // For new users with no stories, use the full screen loading view
                newState.viewState.readerDisplayType = .loading
            }
        case .existingStory(let story):
            if let voice = story.chapters.last?.audioVoice {
                newState.settingsState.voice = voice
            }
            // For existing stories (adding new chapter), we should not go to loading view
            // The snackbar will show the loading state instead
        }
        newState.viewState.loadingState = .writing
    case .failedToCreateChapter,
            .failedToTranslateStory,
            .failedToGenerateImage:
        newState.viewState.readerDisplayType = .normal
        // Also reset writing flag on failure
        newState.viewState.isWritingChapter = false
    case .updateSentenceIndex(let index):
        newState.storyState.currentStory?.currentSentenceIndex = index
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
        newState.storyState.currentStory?.currentPlaybackTime = newState.audioState.audioPlayer.currentTime().seconds
        if let index = newState.currentSpokenWord?.sentenceIndex {
            newState.storyState.currentStory?.currentSentenceIndex = index
        }
    case .selectWord(let word):
        newState.storyState.currentStory?.currentPlaybackTime = word.time
    case .goToNextChapter:
        var newStory = newState.storyState.currentStory
        newStory?.currentChapterIndex += 1
        newState.storyState.currentStory = newStory
        let data = newState.storyState.currentChapterAudioData
        let player = data?.createAVPlayer()
        newState.audioState.audioPlayer = player ?? AVPlayer()
        newState.storyState.currentStory?.currentSentenceIndex = 0
        let chapter = newState.storyState.currentChapter
        newState.storyState.currentStory?.currentPlaybackTime = chapter?.audio.timestamps.first?.time ?? 0.1
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
    case .onLoadedDefinitions(let definitions):
        // Debug - log the state of definitions being loaded
        print("Loading \(definitions.count) definitions")
        print("Definitions with hasBeenSeen=true: \(definitions.filter { $0.hasBeenSeen }.count)")
        
        newState.definitionState.definitions = definitions
    case .onDeletedStory:
        // Just regenerate the view ID - the actual story selection logic is now in onLoadedStories
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
        newState.viewState.readerDisplayType = .normal
        newState.viewState.isShowingSubscriptionSheet = isShowing
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
    case .failedToDefineCharacter:
        newState.viewState.isDefining = false
    case .onTranslatedStory(let story):
        newState.audioState.audioPlayer = AVPlayer()
        newState.settingsState.language = story.language
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
    case .updateStudyAudioPlaying(let isPlaying):
        newState.studyState.isAudioPlaying = isPlaying
    case .updateIsSubscriptionPurchaseLoading(let isLoading):
        newState.subscriptionState.isLoadingSubscriptionPurchase = isLoading
    case .purchaseSubscription:
        newState.subscriptionState.isLoadingSubscriptionPurchase = true
    case .onPurchasedSubscription,
            .failedToPurchaseSubscription:
        newState.subscriptionState.isLoadingSubscriptionPurchase = false
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
            .getCurrentEntitlements,
            .restoreSubscriptions,
            .onRestoredSubscriptions,
            .failedToRestoreSubscriptions,
            .observeTransactionUpdates,
            .validateReceipt,
            .onValidatedReceipt,
            .onGeneratedImage,
            .moderateText,
            .failedToModerateText,
            .prepareToPlayStudyWord,
            .loadChapters,
            .failedToLoadChapters,
            .failedToPrepareStudyWord,
            .checkFreeTrialLimit,
            .failedToSynthesizeAudio,
            .hasReachedDailyLimit,
            .loadThenShowReadySnackbar,
            .loadDefinitionsForStory,
            .pauseStudyAudio,
            .onFinishedLoadedStories,
            .musicTrackFinished:
        break
    }

    return newState
}
