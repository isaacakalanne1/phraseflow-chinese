//
//  FlowTaleMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit
import StoreKit
import AVFoundation

/// Checks if the playback is at or near the end of the audio
/// Used to determine if we should loop back to the start when play is tapped
private func isPlaybackAtEnd(_ state: FlowTaleState) -> Bool {
    let currentTime = state.audioState.audioPlayer.currentTime().seconds

    guard let lastSentence = state.storyState.currentChapter?.sentences.last,
          let lastWordTime = lastSentence.timestamps.last?.time,
          let lastWordDuration = lastSentence.timestamps.last?.duration else {
        return false
    }
    let endTime = lastWordTime + lastWordDuration - 0.5
    
    return currentTime >= endTime
}

let flowTaleMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .studyAction(let studyAction):
        return await studyMiddleware(state, .studyAction(studyAction), environment)
    case .onCreatedChapter(let story):
        if story.imageData == nil,
           let passage = story.chapters.first?.passage {
             return .generateImage(passage: passage, story)
        } else if let chapter = story.chapters[safe: story.currentChapterIndex] {
            return .synthesizeAudio(chapter,
                                    story: story,
                                    voice: state.settingsState.voice,
                                    isForced: true)
        }
        return .saveStoryAndSettings(story)
    case .checkFreeTrialLimit:
        do {
            // 1) Enforce usage limit:
            // If user is free, subscription = nil => total limit (4).
            // If user has subscription => daily limit based on level.
            try environment.enforceChapterCreationLimit(subscription: state.subscriptionState.currentSubscription)

            return nil
        } catch FlowTaleDataStoreError.freeUserChapterLimitReached {
            // If the free user has created all 4 chapters, show an error or prompt to upgrade
            return .hasReachedFreeTrialLimit
        } catch FlowTaleDataStoreError.chapterCreationLimitReached(let nextAvailable) {
            // If the subscribed user hit the daily limit
            return .hasReachedDailyLimit
        } catch {
            // Some other error from generateStory
            return nil
        }

    case .createChapter(let type):
        do {
            try environment.enforceChapterCreationLimit(subscription: state.subscriptionState.currentSubscription)
            let story: Story
            switch type {
            case .newStory:
                let newStory = state.createNewStory()
                story = try await environment.generateStory(story: newStory,
                                                            deviceLanguage: state.deviceLanguage)
            case .existingStory(let existingStory):
                story = try await environment.generateStory(story: existingStory,
                                                            deviceLanguage: state.deviceLanguage)
            }
            return .onCreatedChapter(story: story)
        } catch FlowTaleDataStoreError.freeUserChapterLimitReached {
            return .setSubscriptionSheetShowing(true)
        } catch FlowTaleDataStoreError.chapterCreationLimitReached(let nextAvailable) {
            return .onDailyChapterLimitReached(nextAvailable: nextAvailable)
        } catch {
            return .failedToCreateChapter
        }

    case .onDailyChapterLimitReached(let nextAvailable):
        return .showSnackBar(.dailyChapterLimitReached(nextAvailable: nextAvailable))

    case .failedToCreateChapter,
            .failedToGenerateImage:
        return .showSnackBar(.failedToWriteChapter)
    case .showSnackBar(let type):
        state.appAudioState.audioPlayer.play()
        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbar
        }
        return nil
        
    case .showSnackBarThenSaveStory(let type, let story):
        // First show the snackbar
        state.appAudioState.audioPlayer.play()

        // Hide the snackbar after its duration, then save the story
        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbarThenSaveStoryAndSettings(story)
        }
        // If no duration, just save directly
        return .saveStoryAndSettings(story)
        
    case .hideSnackbarThenSaveStoryAndSettings(_):
        // Get the current story from state, which will have the updated chapter data
        // This ensures we use the latest story with all modifications from the reducer
        if let currentStory = state.storyState.currentStory {
            return .saveStoryAndSettings(currentStory)
        } else if let firstStory = state.storyState.savedStories.first {
            // Fallback to the first story if current story is nil
            return .saveStoryAndSettings(firstStory)
        }
        // No story to save
        return nil
    case .loadStories(let isAppLaunch):
        do {
            let stories = try environment.loadAllStories()
                .sorted(by: { $0.lastUpdated > $1.lastUpdated })
            return .onLoadedStories(stories, isAppLaunch: isAppLaunch)
        } catch {
            return .failedToLoadStories
        }
    case .loadChapters(let story, let isAppLaunch):
        do {
            let chapters = try environment.loadAllChapters(for: story.id)

            return .onLoadedChapters(story, chapters, isAppLaunch: isAppLaunch)
        } catch {
            // 3) Dispatch failure
            return .failedToLoadChapters
        }
    case .loadDefinitions:
        do {
            let definitions = try environment.loadDefinitions()
            return .onLoadedDefinitions(definitions)
        } catch {
            return .failedToLoadDefinitions
        }
    case .deleteStory(let story):
        do {
            try environment.unsaveStory(story)

            // Pass the hidden story ID
            return .onDeletedStory(story.id)
        } catch {
            return .failedToDeleteStory
        }
    case .onDeletedStory:
        return .loadStories(isAppLaunch: false)
    case .synthesizeAudio(let chapter, let story, let voice, let isForced):
        if chapter.audioVoice == state.settingsState.voice,
           chapter.audioSpeed == state.settingsState.speechSpeed,
           !isForced {
            return .playAudio(time: nil)
        }
        do {
            let chapter = try await environment.synthesizeSpeech(for: chapter,
                                                                story: story,
                                                                voice: voice,
                                                                language: story.language)
            return .onSynthesizedAudio(chapter, story, isForced: isForced)
        } catch {
            return .failedToSynthesizeAudio
        }
    case .onSynthesizedAudio(_, let story, _):
        // Determine which type of snackbar to show based on the story
        let isNewStoryCreation = story.chapters.count == 1
        let hasExistingStories = state.storyState.savedStories.count > 1
        
        // We'll let the reducer handle updating the state with this story first 
        // before we do anything else, so we don't need to pass the story along
        
        // Show appropriate snackbar first
        return .showSnackBarThenSaveStory(.chapterReady, story)
    case .playAudio(let timestamp):
        // Check if playback is at or near the end
        let isAtEnd = isPlaybackAtEnd(state)
        
        if isAtEnd {
            await state.audioState.audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 60000), toleranceBefore: .zero, toleranceAfter: .zero)
            print("Looping back to start because play button was tapped at the end")
        } else if let timestamp {
            // If timestamp is provided, use it to seek
            let myTime = CMTime(seconds: timestamp, preferredTimescale: 60000)
            await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        
        // Set the end time to infinity and start playback
        state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 1)
        state.audioState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
        
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .playWord(let word, let story):
        let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
        await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: word.time + word.duration, preferredTimescale: 60000)
        state.audioState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .playSound:
        if state.settingsState.shouldPlaySound {
            state.appAudioState.audioPlayer.play()
        }
        return nil
    case .playMusic:
        state.musicAudioState.audioPlayer.play()
        
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
        
    case .musicTrackFinished(let nextMusicType):
        // Play the next track in the music rotation
        return .playMusic(nextMusicType)
        
    case .stopMusic:
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .pauseAudio:
        state.audioState.audioPlayer.pause()
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .defineCharacter(let timeStampData, let shouldForce):
        do {
            guard let sentence = state.storyState.currentSentence,
                  let story = state.storyState.currentStory,
                  let deviceLanguage = state.deviceLanguage else {
                return .failedToDefineCharacter
            }

            if let definition = state.definitionState.definition(timestampData: timeStampData, in: sentence),
               !shouldForce {
                return .onDefinedCharacter(definition)
            }

            let fetchedDefinitions = try await environment.fetchDefinitions(
                in: sentence,
                story: story,
                deviceLanguage: deviceLanguage
            )

            guard let tappedDefinition = fetchedDefinitions.first(where: { $0.timestampData == timeStampData }) else {
                return .failedToDefineCharacter
            }

            return .onDefinedSentence(sentence, fetchedDefinitions, tappedDefinition: tappedDefinition)

        } catch {
            return .failedToDefineCharacter
        }
    case .onDefinedSentence(let sentence, let definitions, var tappedDefinition):
        guard let firstWord = definitions.first?.timestampData,
              let lastWord = definitions.last?.timestampData else {
            return .saveDefinitions
        }

        let startTime = firstWord.time
        let totalDuration = lastWord.time + lastWord.duration - startTime

        guard let sentenceAudio = AudioExtractor.shared.extractAudioSegment(
            from: state.audioState.audioPlayer,
            startTime: firstWord.time,
            duration: lastWord.time + lastWord.duration - firstWord.time
        ) else {
            return .saveDefinitions
        }

        do {
            try environment.saveSentenceAudio(sentenceAudio, id: sentence.id)
            tappedDefinition.sentenceId = sentence.id
            return .onDefinedCharacter(tappedDefinition)
        } catch {
            return .saveDefinitions
        }
    case .onDefinedCharacter:
        return .saveDefinitions
    case .saveDefinitions:
        do {
            // Just save all definitions at once
            try environment.saveDefinitions(state.definitionState.definitions)
            return .onSavedDefinitions
        } catch {
            return .failedToSaveDefinitions
        }
    case .deleteDefinition(let definition):
        do {
            // Delete the definition using its unique id
            try environment.deleteDefinition(with: definition.id)
            return .onDeletedDefinition
        } catch {
            print("Failed to delete definition: \(error)")
            return .failedToDeleteDefinition
        }
    case .onDeletedDefinition:
        return .loadDefinitions
    case .onSavedDefinitions:
        return .loadDefinitions
    case .selectChapter:
        return .onSelectedChapter
    case .onSelectedChapter:
        return .selectTab(.reader, shouldPlaySound: false)
    case .saveStoryAndSettings(var story):
        do {
            for (index, chapter) in story.chapters.enumerated() {
                try environment.saveChapter(chapter, storyId: story.id, chapterIndex: index + 1)
            }

            try environment.saveStory(story)
            try environment.saveAppSettings(state.settingsState)

            return .onSavedStoryAndSettings
        } catch {
            return .failedToSaveStoryAndSettings
        }
    case .onSavedStoryAndSettings:
        return .loadStories(isAppLaunch: false)
    case .setMusicVolume(let volume):
        state.musicAudioState.audioPlayer.setVolume(volume.float, fadeDuration: 0.2)
        return nil
    case .selectWord(let word):
        if state.audioState.isPlayingAudio {
            let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
            await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 60000)
            state.audioState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
        } else {
            return .playWord(word, story: state.storyState.currentStory)
        }
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
        
    case .updatePlayTime:
        let time = state.audioState.audioPlayer.currentTime().seconds
        if let lastSentence = state.storyState.currentChapter?.sentences.last,
           let lastWordTime = lastSentence.timestamps.last?.time,
           let lastWordDuration = lastSentence.timestamps.last?.duration,
           time > lastWordTime + lastWordDuration {
            return .pauseAudio
        }
        return nil
    case .goToNextChapter:
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .selectVoice,
            .updateLanguage,
            .updateSpeechSpeed,
            .updateShowDefinition,
            .updateShowEnglish,
            .updateDifficulty,
            .updateColorScheme,
            .updateShouldPlaySound:
        return .saveAppSettings
    case .saveAppSettings:
        do {
            try environment.saveAppSettings(state.settingsState)
            return nil
        } catch {
            return .failedToSaveAppSettings
        }
    case .loadAppSettings:
        do {
            let settings = try environment.loadAppSettings()
            return .onLoadedAppSettings(settings)
        } catch {
            return .failedToLoadAppSettings
        }
    case .checkDeviceVolumeZero:
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            return nil
        }
        return audioSession.outputVolume == 0.0 ? .showSnackBar(.deviceVolumeZero) : nil
    case .fetchSubscriptions:
        environment.validateReceipt()
        do {
            let subscriptions = try await environment.getProducts()
            return .onFetchedSubscriptions(subscriptions)
        } catch {
            return .failedToFetchSubscriptions
        }
    case .purchaseSubscription(let product):
        do {
            try await environment.purchase(product)
        } catch {
            return .failedToPurchaseSubscription
        }
        return .onPurchasedSubscription
    case .onPurchasedSubscription:
        return .getCurrentEntitlements
    case .restoreSubscriptions:
        environment.validateReceipt()
        do {
            try await AppStore.sync()
        } catch {
            return .failedToRestoreSubscriptions
        }
        return .onRestoredSubscriptions
        
    case .validateReceipt:
        environment.validateReceipt()
        return .onValidatedReceipt
    case .getCurrentEntitlements:
        var entitlements: [VerificationResult<Transaction>] = []
        for await result in Transaction.currentEntitlements {
            entitlements.append(result)
        }
        return .updatePurchasedProducts(entitlements, isOnLaunch: true)
    case .observeTransactionUpdates:
        var entitlements: [VerificationResult<Transaction>] = []
        for await result in Transaction.updates {
            entitlements.append(result)
        }
        return .updatePurchasedProducts(entitlements, isOnLaunch: false)
    case .updatePurchasedProducts(let entitlements, let isOnLaunch):
        for result in entitlements {
            switch result {
            case .unverified(let transaction, _),
                    .verified(let transaction):
                if transaction.revocationDate == nil && !isOnLaunch {
                    return .showSnackBar(.subscribed)
                } else {
                    return nil
                }
            }
        }
        return nil
    case .generateImage(let passage, let story):
        do {
            let data = try await environment.generateImage(with: passage)
            return .onGeneratedImage(data, story)
        } catch {
            return .failedToGenerateImage
        }
    case .onGeneratedImage(let data, var story):
        story.imageData = data
        if let chapter = story.chapters[safe: story.currentChapterIndex] {
            return .synthesizeAudio(chapter,
                                    story: story,
                                    voice: state.settingsState.voice,
                                    isForced: true)
        }
        return .saveStoryAndSettings(story)
    case .updateStudiedWord:
        return .saveDefinitions
    case .onLoadedAppSettings:
        if state.settingsState.isPlayingMusic {
            return .playMusic(.whispersOfTheForest)
        }
        return nil
    case .updateStorySetting(let setting):
        switch setting {
        case .random:
            return nil
        case .customPrompt(let prompt):
            let isNewPrompt = !state.settingsState.customPrompts.contains(prompt)
            return isNewPrompt ? .moderateText(prompt) : nil
        }
    case .moderateText(let prompt):
        do {
            let response = try await environment.moderateText(prompt)
            return .onModeratedText(response, prompt)
        } catch {
            return .failedToModerateText
        }
    case .onModeratedText(let response, let prompt):
        return response.didPassModeration ? .passedModeration(prompt) : .didNotPassModeration
    case .passedModeration:
        try? environment.saveAppSettings(state.settingsState)
        return .showSnackBar(.passedModeration)
    case .didNotPassModeration,
            .failedToModerateText:
        return .showSnackBar(.didNotPassModeration)
    case .selectTab(_, let shouldPlaySound):
        return shouldPlaySound ? .playSound(.tabPress) : nil
    case .onLoadedStories(let stories, let isAppLaunch):
        return .onFinishedLoadedStories
    case .onFinishedLoadedStories:
        if let story = state.storyState.currentStory,
           story.chapters.isEmpty {
            return .loadChapters(story, isAppLaunch: false)
        }
        return nil
    case .onLoadedChapters(let story, let chapters, let isAppLaunch):
        return isAppLaunch ? .showSnackBar(.welcomeBack) : nil
    case .deleteCustomPrompt:
        return .saveAppSettings
    case .onLoadedDefinitions:
        return .refreshDefinitionView
    case .setSubscriptionSheetShowing(let isShowing):
        if isShowing {
            return .hideSnackbar
        }
        return nil
    case .failedToLoadStories,
            .failedToSaveStory,
            .failedToDefineCharacter,
            .onPlayedAudio,
            .failedToSynthesizeAudio,
            .refreshChapterView,
            .refreshDefinitionView,
            .failedToDeleteStory,
            .failedToSaveAppSettings,
            .failedToLoadAppSettings,
            .refreshTranslationView,
            .failedToLoadDefinitions,
            .failedToSaveDefinitions,
            .failedToSaveStoryAndSettings,
            .refreshStoryListView,
            .onFetchedSubscriptions,
            .failedToFetchSubscriptions,
            .failedToPurchaseSubscription,
            .onRestoredSubscriptions,
            .failedToRestoreSubscriptions,
            .updateAutoScrollEnabled,
            .hideSnackbar,
            .updateCustomPrompt,
            .updateIsShowingCustomPromptAlert,
            .failedToLoadChapters,
            .dismissFailedModerationAlert,
            .showModerationDetails,
            .updateIsShowingModerationDetails,
            .showDailyLimitExplanationScreen,
            .hasReachedFreeTrialLimit,
            .hasReachedDailyLimit,
            .showFreeLimitExplanationScreen,
            .selectStoryFromSnackbar,
            .onValidatedReceipt,
            .updateIsSubscriptionPurchaseLoading,
            .updateCurrentSentence,
            .failedToDeleteDefinition:
        return nil
    }
}
